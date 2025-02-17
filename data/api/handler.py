import json

def lambda_handler(event, context):
    # Generate a DataFrame with game scores
    data = {
        "game": ["Game1", "Game2", "Game3"],
        "score": [9.2, 8.4, 8.6]  # Example scores
    }
    # Handle query parameters
    query_params = event.get("queryStringParameters", {})
    name = query_params.get("name", "you")
    
    # Create the response message
    average_score = sum(data["score"]) / len(data["score"])
    message = f"Hello {name}! The score is {average_score}."
    print(message)

    # Return the HTTP response
    return {
        "statusCode": 200,
        "body": json.dumps({"message": message}),
        "headers": {
            "Content-Type": "application/json"
        }
    }


if __name__ == "__main__":
    event_test = {"queryStringParameters": {"name": "Luciano"}}
    response = lambda_handler(event_test, None)
    print(response)

print(3)