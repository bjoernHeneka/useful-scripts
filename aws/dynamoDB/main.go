package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/davecgh/go-spew/spew"
	"os"
	"sync"
)

const tableName = "temp_constraints"

var wg sync.WaitGroup

func main() {
	deleteAll("122212-2222-4262-a0b0-d14b76f7f047")
	wg.Wait()
}
func deleteAll(start string) {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	
	// Create DynamoDB client
	svc := dynamodb.New(sess)
	
	// key := expression.Key("correlationKey").Equal(expression.Value("1482226"))
	// filt.And(expression.Name("LastEvaluatedKey").Equal(expression.Value("1d4eff30-99a5-42c3-a557-456113519e94")))4670559
	
	// Or we could get by ratings and pull out those with the right year later
	//    filt := expression.Name("info.rating").GreaterThan(expression.Value(min_rating))
	
	// Get back the title, year, and rating
	
	descInput := &dynamodb.DescribeTableInput{
		TableName: aws.String(tableName),
	}
	descResult, err := svc.DescribeTable(descInput)
	keyName := *descResult.Table.KeySchema[0].AttributeName
	spew.Dump(keyName)
	
	params := &dynamodb.ScanInput{
		Limit: aws.Int64(500),
		ExclusiveStartKey: map[string]*dynamodb.AttributeValue{
			keyName: {
				S: aws.String(start),
			},
		},
		TableName: aws.String(tableName),
	}
	
	spew.Dump(params)
	
	// Make the DynamoDB Query API call
	result, err := svc.Scan(params)
	if err != nil {
		fmt.Println("Query API call failed:")
		fmt.Println((err.Error()))
		os.Exit(1)
	}
	
	sem := make(chan bool, 1000)
	
	for _, i := range result.Items {
		
		if err != nil {
			fmt.Println("Got error unmarshalling:")
			fmt.Println(err.Error())
			os.Exit(1)
		}
		
		keyValue := *i[keyName].S
		
		sem <- true
		wg.Add(1)
		go func(keyValue string) {
			// switch channel
			
			input := &dynamodb.DeleteItemInput{
				Key: map[string]*dynamodb.AttributeValue{
					keyName: {
						S: aws.String(keyValue),
					},
				},
				TableName: aws.String(tableName),
			}
			
			fmt.Printf("Deleting item with key: %s and value: %v \n", keyName, keyValue)
			
			_, err := svc.DeleteItem(input)
			if err != nil {
				fmt.Println("Got error calling DeleteItem")
				fmt.Println(err.Error())
				return
			}
			<-sem
			defer wg.Done()
		}(keyValue)
		
	}
	
	if len(result.LastEvaluatedKey) > 0 {
		deleteAll(result.LastEvaluatedKey[keyName].String())
	}
	
}
