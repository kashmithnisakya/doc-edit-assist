import:py requests;
import:py json;

walker health_chech{
    has user_text: str;

    obj __specs__ {
        static has auth: bool = False;
    }

    can run_jivas with `root entry{
        base_url = "http://localhost:8000";

        # logging 
        data = {
        "email": "admin@jivas.com",
        "password": "password"
        };
        response = requests.post(f"{base_url}/user/login", json=data);
        jivas_token = response.json().get("token", "");


        data = {
            "agent_id": "n:Agent:68627bdb106bfcc829f696b8",
            "utterance": self.user_text,
            "channel": "",
            "session_id": "1d0e9f3e-564c-4b1d-8de5-ec85f334e56c",
            "tts": True,
            "verbose": False,
            "streaming": False
        };

        headers = {
            "Authorization": f"Bearer {jivas_token}",
            "Content-Type": "application/json"
        };

        response = requests.post(f"{base_url}/interact", json=data, headers=headers);

        print("Status Code:", response.status_code);
        print("Response:", response.json());

        report response.json();
    }
}