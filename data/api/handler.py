import json

def lambda_handler(event, context):
    # Obtém os parâmetros da query string (se existirem)
    params = event.get('queryStringParameters') or {}
    number_str = params.get('number')

    # Se não for passado o parâmetro "number", retorna uma mensagem padrão
    if number_str is None:
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Bem-vindo à API! Envie um parâmetro "number" para multiplicá-lo por 2.'
            })
        }
    
    try:
        # Converte o parâmetro para número (pode ser inteiro ou float)
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
        # Caso a conversão falhe, retorna um erro
        return {
            'statusCode': 400,
            'body': json.dumps({
                'error': 'O parâmetro "number" deve ser um número válido.'
            })
        }
