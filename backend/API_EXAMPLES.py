"""
api URL:  http://127.0.0.1:5000/api/create_user
body:
{
    "firstname" :"obied",
    "password" : "haddad",
    "phonenum" : "0509021620"
}

response:
{
    'message': 'User created successfully',
    'username': "obied",
    'phonenum': "0509021620"
}

other response:
{
    "error": "User with this username already exists"
}

api URL:  http://127.0.0.1:5000/api/user_verfication
body:
{
    "username" :"obied",
    "password" : "haddad",
}

response:
{
    "message": "User Verified",
    "user_type": "regular",
    "userid": "e7f67d04-341d-4f00-b022-ee1af42f6141"
}

other response:
{
    "error": "Invalid username or password"
}

api URL: http://127.0.0.1:5000/api/update_preference
body:
{
    "user_id": "4fd1403c-e3ab-4089-92f2-9c02acbacf38",
    "preference": "wifi-1, parking-0, showers"
}

response:
{
    "message": "Preference updated successfully"
}

other response:
{
    "error": "User ID and preference are required"
}

other response:
{
    "error": "User ID must be a valid UUID"
}
"""