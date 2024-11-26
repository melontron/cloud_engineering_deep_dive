exports.handler = async (event) => {
    console.log("Lambda function invoked!");
    return {
        statusCode: 200,
        body: JSON.stringify('Hello from Lambda!'),
    };
}; 