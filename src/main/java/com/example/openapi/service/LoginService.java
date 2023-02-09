package com.example.openapi.service;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.GeneralSecurityException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import javax.servlet.http.HttpServletRequest;

@Service
@Slf4j
public class LoginService {

    // accessToken을 받기 위한 메서드
    public String getAccessToken(String authorize_code) {
        String access_Token = "";
        String refresh_Token = "";
        String reqURL = "https://kauth.kakao.com/oauth/token";

        try {
            URL url = new URL(reqURL);

            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            // POST 요청을 위해 기본값이 false인 setDoOutput을 true로 설정
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);

            // POST 요청에 필요로 요구하는 파라미터 스트림을 통해 전송
            BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(conn.getOutputStream()));
            StringBuffer sb = new StringBuffer();
            sb.append("grant_type=authorization_code");

            sb.append("&client_id=2270f6337814fd5b2aa1f569bb282d8e"); //본인이 발급받은 key
            sb.append("&redirect_uri=http://localhost:8080/AfterloginKakao"); // 본인이 설정한 주소

            sb.append("&code=" + authorize_code);
            bw.write(sb.toString());
            bw.flush();

            // 결과 코드가 200이라면 성공
            int responseCode = conn.getResponseCode();
            System.out.println("responseCode : " + responseCode);

            // 요청을 통해 얻은 JSON타입의 Response 메세지 읽어오기
            BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String line = "";
            String result = "";

            while ((line = br.readLine()) != null) {
                result += line;
            }
            System.out.println("response body : " + result);

            // Gson 라이브러리에 포함된 클래스로 JSON파싱 객체 생성
            JsonParser parser = new JsonParser();
            JsonElement element = parser.parse(result);

            access_Token = element.getAsJsonObject().get("access_token").getAsString();
            refresh_Token = element.getAsJsonObject().get("refresh_token").getAsString();

            System.out.println("access_token : " + access_Token);
            System.out.println("refresh_token : " + refresh_Token);

            br.close();
            bw.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return access_Token;
    }

    public HashMap<String, Object> getUserInfo(String access_Token) {

        // 요청하는 클라이언트마다 가진 정보가 다를 수 있기에 HashMap타입으로 선언
        HashMap<String, Object> userInfo = new HashMap<String, Object>();
        String reqURL = "https://kapi.kakao.com/v2/user/me";
        try {
            URL url = new URL(reqURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");

            // 요청에 필요한 Header에 포함될 내용
            conn.setRequestProperty("Authorization", "Bearer " + access_Token);

            int responseCode = conn.getResponseCode();
            System.out.println("responseCode : " + responseCode);

            BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));

            String line = "";
            String result = "";

            while ((line = br.readLine()) != null) {
                result += line;
            }
            System.out.println("response body : " + result);

            JsonParser parser = new JsonParser();
            JsonElement element = parser.parse(result);

            JsonObject properties = element.getAsJsonObject().get("properties").getAsJsonObject();
            JsonObject kakao_account = element.getAsJsonObject().get("kakao_account").getAsJsonObject();

            String name = properties.getAsJsonObject().get("nickname").getAsString();
//            String email = kakao_account.getAsJsonObject().get("email").getAsString();

            userInfo.put("name", name);
//            userInfo.put("email", email);

        } catch (IOException e) {
            e.printStackTrace();
        }
        return userInfo;
    }

    // Naver UserInfo 받아오기
    public String getUserInfoNaver(String access_token) {
        String token = access_token;
        String header = "Bearer " + token;
        String name = "";
        try {
            String apiURL = "https://openapi.naver.com/v1/nid/me";
            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("Authorization", header);
            int responseCode = con.getResponseCode();
            BufferedReader br;
            if (responseCode == 200) { // 정상 호출
                br = new BufferedReader(new InputStreamReader(con.getInputStream()));
            } else {  // 에러 발생
                br = new BufferedReader(new InputStreamReader(con.getErrorStream()));
            }
            String result = "";
            String inputLine;
            StringBuffer response = new StringBuffer();
            while ((inputLine = br.readLine()) != null) {
                response.append(inputLine);
                result += inputLine;
            }


            JsonParser parser = new JsonParser();
            JsonElement element = parser.parse(result);

            log.info("result : " + result);
            log.info("element : " + element);

            JsonObject properties = element.getAsJsonObject().get("response").getAsJsonObject();

            name = properties.getAsJsonObject().get("name").getAsString();
            log.info("name : " + name);

            br.close();
            System.out.println(response.toString());
        } catch (Exception e) {
            System.out.println(e);
        }
        return name;
    }

    // Google Token
    public String getGoogleToken(String getCode){
        // Access Token 받아오기
        String access_Token = "";
        String refresh_Token = "";

        String apiURL = "https://www.googleapis.com/oauth2/v4/token";
//        String reqURL = "https://accounts.google.com/o/oauth2/auth";
        String clientId = "175958294391-mhl3hcs6a4v773jnvf294d00vvqtnn2h.apps.googleusercontent.com";
        String clientSecret = "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";
        String redirectUrl = "http://localhost:8080/AfterloginGoogle";
        String scope = "https://www.googleapis.com/auth/drive.readonly";
        String code = getCode;


        try {
            URL url = new URL(apiURL);

            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            // POST 요청을 위해 기본값이 false인 setDoOutput을 true로 설정
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);

            // POST 요청에 필요로 요구하는 파라미터 스트림을 통해 전송
            BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(conn.getOutputStream()));
            StringBuffer sb = new StringBuffer();
            sb.append("grant_type=authorization_code");
            sb.append("&client_id=175958294391-mhl3hcs6a4v773jnvf294d00vvqtnn2h.apps.googleusercontent.com");
            sb.append("&client_secret=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");
            sb.append("&redirect_uri=http://localhost:8080/AfterloginGoogle");
            sb.append("&code="+code);
            sb.append("&state=url_parameter");
            bw.write(sb.toString());
            bw.flush();

            //결과 코드가 200이라면 성공
            int responseCode = conn.getResponseCode();
            if(responseCode==200){
                //요청을 통해 얻은 JSON타입의 Response 메세지 읽어오기
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String line = "";
                String result = "";

                while ((line = br.readLine()) != null) {
                    result += line;
                }

                //Gson 라이브러리에 포함된 클래스로 JSON파싱 객체 생성
                JsonParser parser = new JsonParser();
                JsonElement element = parser.parse(result);
                System.out.println("result : "+result);
                access_Token = element.getAsJsonObject().get("access_token").getAsString();
                //refresh_Token = element.getAsJsonObject().get("refresh_token").getAsString();
                br.close();
                bw.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return access_Token;
    }

    public String getGoogleUserInfo(String access_Token) {
//        HashMap<String, Object> userInfo = new HashMap<String, Object>();
        // 요청하는 클라이언트마다 가진 정보가 다를 수 있기에 HashMap타입으로 선언
        String reqURL = "https://www.googleapis.com/userinfo/v2/me?access_token=" + access_Token;
        String name = null;
        try {
            URL url = new URL(reqURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            //요청에 필요한 Header에 포함될 내용
            conn.setRequestProperty("Authorization", "Bearer " + access_Token);

            int responseCode = conn.getResponseCode();
            System.out.println("responseCode : " + responseCode);
            if (responseCode == 200) {
                BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));

                String line = "";
                String result = "";

                while ((line = br.readLine()) != null) {
                    result += line;
                }
                JsonParser parser = new JsonParser();
                System.out.println("result : " + result);
                JsonElement element = parser.parse(result);

                name = element.getAsJsonObject().get("name").getAsString();

                System.out.println("login Controller : " + name);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return name;
    }
}