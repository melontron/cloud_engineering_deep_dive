const axios = require('axios');

exports.handler = async (event) => {
    const url = 'https://jsonplaceholder.typicode.com/posts';

    try {
        // Make a GET request to the JSONPlaceholder API 
        const response = await axios.get(url);
        
        // Return the data
        return {
            statusCode: 200,
            body: JSON.stringify(response.data),
        };
    } catch (error) {
        // Handle any errors that occur during the API call
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message }),
        };
    }
};
