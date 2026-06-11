from fastapi.testclient import TestClient

import main


client = TestClient(main.app)


def test_verify_google_token_success(monkeypatch):
    # def fake_verify_oauth2_token(token, request, audience):
    #     assert token == "valid-token"
    #     assert audience == main.ALLOWED_CLIENT_IDS
    #     return {
    #         "sub": "google-user-123",
    #         "email": "user@example.com",
    #         "name": "Test User",
    #         "picture": "https://example.com/avatar.png",
    #         "email_verified": True,
    #     }

    # monkeypatch.setattr(main.id_token, "verify_oauth2_token", fake_verify_oauth2_token)

    id_token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjdiMDIxNjcxZWRlOTBlZTVhMzc1YzAyMmE1MjNkNDkwMTgxYTJjOWQiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJhenAiOiIzOTM1MDk1NDI3NDItMDYyNXI1ZHY3cWxyc2ZhbDgzZjR2dHZwZDllczM5ZTYuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJhdWQiOiIzOTM1MDk1NDI3NDItbTZ0ZTZrOW8zdjQ0bzQ3M2oyZjlhYzFiMzBxYmRmcnAuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTQxMjUyMTQ4NTYyNjk0MzQ1NjkiLCJlbWFpbCI6InJpY2htb25rZXlubkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXRfaGFzaCI6ImI3T05hUkNycTBZTE15U01GbjVfSkEiLCJub25jZSI6Ijd5NzBDLVljVG8xdGZOTGNnbkV0dXVCemx6OVVxNVNGcDh5ZDBtbERZT0EiLCJuYW1lIjoieHVlaHVhIGhvdSIsInBpY3R1cmUiOiJodHRwczovL2xoMy5nb29nbGV1c2VyY29udGVudC5jb20vYS9BQ2c4b2NKejBfYklMTW5idU9NT0t2aUxXZGV3eHlfSHJoNVF0QXB5ZFRLM2pWTzJEcWNXQ2lzPXM5Ni1jIiwiZ2l2ZW5fbmFtZSI6Inh1ZWh1YSIsImZhbWlseV9uYW1lIjoiaG91IiwiaWF0IjoxNzgxMTYyODcyLCJleHAiOjE3ODExNjY0NzJ9.zOPcI1aHWMuvUCs5ox64sRFiW-kkBSEovKTKYXdkbgUM8mvqoLJsAG8xngr_QwEqSrtVAAqOIiIqd_a6qoG5lDG5wTkbkADy5HgErCV_CGrCZBWmj8WxaCo8PDIEzpe3xS0MKyChN_-zc2BnAvvjhIXks3dMqMh4fZ34_V1WIG3luF6YSXeCpQ8eN8SMxI5lXs515mkhmDFe1MM-XP5UgSAqdb6b_mAQ83JuuSvJulzTmO66NU8ZP-RgNLNs1-yXvbD3ASGcGCuArj8fKPaemJPzmYHrMdJYyITRfKJSXa2uH-wfLU9r19wnQVrWLmYFCm7yciZTFV62wLyvKqi-hQ"
    response = client.post("/auth/google", json={"id_token": id_token})
    print("resp:", response.json())
    assert response.status_code == 200

    # assert response.json() == {
    #     "google_user_id": "google-user-123",
    #     "email": "user@example.com",
    #     "name": "Test User",
    #     "picture": "https://example.com/avatar.png",
    #     "email_verified": True,
    # }


def test_verify_google_token_invalid_token(monkeypatch):
    def fake_verify_oauth2_token(token, request, audience):
        raise ValueError("Token used too late")

    #monkeypatch.setattr(main.id_token, "verify_oauth2_token", fake_verify_oauth2_token)

    response = client.post("/auth/google", json={"id_token": "bad-token"})

    assert response.status_code == 401
    assert response.json()["detail"].startswith("Invalid idToken:")


def test_verify_google_token_email_not_verified(monkeypatch):
    def fake_verify_oauth2_token(token, request, audience):
        return {
            "sub": "google-user-123",
            "email": "user@example.com",
            "email_verified": False,
        }

    #monkeypatch.setattr(main.id_token, "verify_oauth2_token", fake_verify_oauth2_token)

    response = client.post("/auth/google", json={"id_token": "valid-token"})

    assert response.status_code == 401
    assert response.json() == {"detail": "Email not verified by Google"}