import json

def lambda_handler(event, context):
    # Get the query string parameters (if any)
    params = event.get('queryStringParameters') or {}
    number_str = params.get('number')

    # If the "number" parameter is not provided, return a default message
    if number_str is None:
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Welcome to the API! Provide a number parameter to multiply it by 2.'
            })
        }
    
    try:
        # Convert the parameter to a number (can be integer or float)
        number = float(number_str)
        result = number * 2
        return {
            'statusCode': 200,
            'body': json.dumps({
                'number': number,
                'result': result
            })
        }
    except ValueError:
        # If conversion fails, return an error
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': 'The number parameter must be a valid number.'
            })
        }


# Local testing block
if __name__ == '__main__':
    # Simulate an event with or without the "number" parameter
    # Example without parameter:
    event_default = {"queryStringParameters": None}
    print("Test without parameter:")
    print(lambda_handler(event_default, None))

    # Example with the "number" parameter:
    event_with_number = {"queryStringParameters": {"number": "5"}}
    print("\nTest with parameter number=5:")
    print(lambda_handler(event_with_number, None))
