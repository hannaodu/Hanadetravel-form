const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');

const dynamoClient = new DynamoDBClient({ region: 'eu-west-2' });

exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    
    try {
        let body;
        try {
            body = JSON.parse(event.body);
        } catch (parseError) {
            return {
                statusCode: 400,
                body: JSON.stringify({ message: 'Invalid JSON' })
            };
        }
        
        const { name, email, message } = body;
        
        if (!name || !email || !message) {
            return {
                statusCode: 400,
                body: JSON.stringify({ message: 'Missing required fields' })
            };
        }
        
        const submissionId = Date.now().toString();
        const timestamp = new Date().toISOString();
        
        // Save to DynamoDB ONLY (skip email for now)
        const putParams = {
            TableName: process.env.TABLE_NAME,
            Item: {
                submissionId: { S: submissionId },
                name: { S: name },
                email: { S: email },
                message: { S: message },
                timestamp: { S: timestamp }
            }
        };
        
        await dynamoClient.send(new PutItemCommand(putParams));
        console.log('Data saved to DynamoDB');
        
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            body: JSON.stringify({ 
                message: 'Form submitted successfully!',
                submissionId: submissionId
            })
        };
        
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            body: JSON.stringify({ 
                message: 'Internal server error: ' + error.message
            })
        };
    }
};
