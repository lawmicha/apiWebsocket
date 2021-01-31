## iOS App connected to Websocket API (Amazon API Gateway)

My experience setting up an iOS app to connect to an API Gateway websocket API.

Amplify CLI version 4.40.0


1. `amplify init`

2. `amplify add api`

```
? Please select from one of the below mentioned services: REST
? Provide a friendly name for your resource to be used as a label for this category in the project: apid4887d36
? Provide a path (e.g., /book/{isbn}): /todo
? Choose a Lambda source Create a new Lambda function
? Provide an AWS Lambda function name: apiwebsocket2790d4d8
? Choose the runtime that you want to use: NodeJS
? Choose the function template that you want to use: Serverless ExpressJS function (Integration with API Gateway)

Available advanced settings:
- Resource access permissions
- Scheduled recurring invocation
- Lambda layers configuration

? Do you want to configure advanced settings? Yes
? Do you want to access other resources in this project from your Lambda function? Yes
? Select the category 

You can access the following resource attributes as environment variables from your Lambda function
        ENV
        REGION
? Do you want to invoke this function on a recurring schedule? No
? Do you want to configure Lambda layers for this function? No
? Do you want to edit the local lambda function now? No
Successfully added resource apiwebsocket2790d4d8 locally.

Next steps:
Check out sample function code generated in <project-dir>/amplify/backend/function/apiwebsocket2790d4d8/src
"amplify function build" builds all of your functions currently in the project
"amplify mock function <functionName>" runs your function locally
"amplify push" builds all of your local backend resources and provisions them in the cloud
"amplify publish" builds all of your local backend and front-end resources (if you added hosting category) and provisions them in the cloud
Succesfully added the Lambda function locally
? Restrict API access No
? Do you want to add another path? No
Successfully added resource apid4887d36 locally

Some next steps:
"amplify push" will build all your local backend resources and provision it in the cloud
"amplify publish" will build all your local backend and frontend resources (if you have hosting category added) and provision it in the cloud
```

3. `amplify push`

4. `amplify console api` and select REST, and you should land on the API Gateway console. Take note of the lambda that is integrated into the API methods

5. Create a websocket API. Go to APIGateway console, and create a websocket API. I partially followed the beginning of the steps at this [link](https://www.freecodecamp.org/news/real-time-applications-using-websockets-with-aws-api-gateway-and-lambda-a5bb493e9452/)

The end result should be a websocket API with `$connect`, `$disconnect`, and `$default` connected to the same Lambda.

6. Go to your lambda, and update the code in `app.js` and add a new route for `/`
```javascript
app.get('/', function(req, res) {
  console.log("Request: " + JSON.stringify(req.apiGateway.event));
  console.log("RequestContext: " + JSON.stringify(req.apiGateway.event.requestContext));
  res.json({success: 'get call succeed!', url: req.url});
});
```

Note: If you are not using [aws-serverless-express](https://www.npmjs.com/package/aws-serverless-express) that is provisioned as part of the initial steps, make sure you return a response in the event handler accordingly, see this for more details: https://aws.amazon.com/premiumsupport/knowledge-center/malformed-502-api-gateway/

7. Click Deploy, and test the Lambda using the Test button at the top right. You can use a payload like so:
```json
{
  "requestContext": {
    "connectionId": "123"
  }
}
```

8. Go back to your websocket API and click on Stages, select your stage, and make note of the WebSocket URL. It should be in the format of `wss://endpoint.execute-api.region.amazonaws.com/[stage]`

9. Install wscat to connect to the websocket, `npm install -g wscat`

Reference: https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-how-to-call-websocket-api-wscat.html

10. Connect to your websocket from the URL in step 8
```
> wscat -c wss://endpoint.execute-api.us-west-2.amazonaws.com/production
Connected (press CTRL+C to quit)
```

You can try sending a message like 
```
> {"action" : "onMessage" , "message" : "Hello everyone!!!!!!!!"}
```
and check Cloudwatch logs to make sure that the data is being sent as the `body` of the request

11. Sending data back to a connected client (https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-how-to-call-websocket-api-connections.html) 
Did not try this out.

12. `pod install`

13. Update the endpoint in `ContentView.swift` to your Websocket API endpoint and click connect

Stuck on a step? Want to improve this experience? Feel free to open an issue or pull request!