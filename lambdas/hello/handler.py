import json
import pandas as pd

def lambda_handler(event, context):
    # Generate a DataFrame with game scores
    data = {
        "game": ["Game1", "Game2", "Game3"],
        "score": [9.2, 8.4, 8.6]  # Example scores
    }
    df = pd.DataFrame(data)
    
    # Calculate the average score
    average_score = round(df["score"].mean(), 1)
    
    # Handle query parameters
    query_params = event.get("queryStringParameters", {})
    name = query_params.get("name", "you")
    
    # Create the response message
    message = f"Hello {name}! The score is {average_score}."
    
    # Return the HTTP response
    return {
        "statusCode": 200,
        "body": json.dumps({"message": message}),
        "headers": {
            "Content-Type": "application/json"
        }
    }
