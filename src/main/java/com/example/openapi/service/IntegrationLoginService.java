package com.example.openapi.service;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

@Service
@Slf4j
public class IntegrationLoginService {

    public String getAccessToken(String authorize_code,String state) throws Exception{
        String access_Token = "";
        String refresh_Token = "";
        String reqURL = "";
        String clientId = "";   // 본인이 발급받은 key
        String clientSecret = "";   // 본인이 발급받은 key의 비밀번호(노출하면 안됨)
        String redirectURI = "http://localhost:8080/IntegrationLogin";    // 본인이 설정한 주소
        int codeLen = authorize_code.length();

        // Kakao Login
        if(codeLen == 86) {
            clientId = "2270f6337814fd5b2aa1f569bb282d8e";
            reqURL = "https://kauth.kakao.com/oauth/token";

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

                sb.append("&client_id=" + clientId);
                sb.append("&redirect_uri=" + redirectURI);

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

                br.close();
                bw.close();
            } catch (IOException e) {
                e.printStackTrace();
            }

        // Naver Login
        } else if(codeLen == 18) {
            clientId = "8Z037cpOMLJbG8tl0BSu";
            clientSecret = "Ku0kyXmbCc";
            reqURL = "https://nid.naver.com/oauth2.0/token?grant_type=authorization_code&";
            reqURL += "client_id=" + clientId;
            reqURL += "&client_secret=" + clientSecret;
            reqURL += "&redirect_uri=" + redirectURI;
            reqURL += "&code=" + authorize_code;
            reqURL += "&state=" + state;

            try {
                URL url = new URL(reqURL);
                HttpURLConnection con = (HttpURLConnection)url.openConnection();
                con.setRequestMethod("GET");
                int responseCode = con.getResponseCode();
                BufferedReader br;
                System.out.print("responseCode="+responseCode);
                if(responseCode==200) { // 정상 호출
                    br = new BufferedReader(new InputStreamReader(con.getInputStream()));
                } else {  // 에러 발생
                    br = new BufferedReader(new InputStreamReader(con.getErrorStream()));
                }
                String result = "";
                String inputLine;
                StringBuffer res = new StringBuffer();
                while ((inputLine = br.readLine()) != null) {
                    res.append(inputLine);
                    result += inputLine;
                }

                JsonParser parser = new JsonParser();
                JsonElement element = parser.parse(result);

                access_Token = element.getAsJsonObject().get("access_token").getAsString();

                log.info("access_token : " + access_Token);

                br.close();
                if(responseCode==200) {
                    System.out.println(res.toString());
                }
            } catch (Exception e) {
                System.out.println(e);
                return "/afterLogin";
            }

        // Google Login
        } else if(codeLen == 73) {
            clientId = "175958294391-mhl3hcs6a4v773jnvf294d00vvqtnn2h.apps.googleusercontent.com";
            clientSecret = "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";
            reqURL = "https://www.googleapis.com/oauth2/v4/token";
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
                sb.append("&client_id=" + clientId);
                sb.append("&client_secret=" + clientSecret);
                sb.append("&redirect_uri=" + redirectURI);
                sb.append("&code="+ authorize_code);
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

                    log.info("access_token : " + access_Token);

                    br.close();
                    bw.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return access_Token;
    }

    public String getUserInfo(String code, String access_Token) throws Exception{
        String name = "";
        String reqURL = "";

        // 각 서버마다 code의 글자 길이가 다름 - KaKao(86자리)/Naver(18자리)/Google(73자리)
        int codeLen = code.length();

        // Kakao UserInfo
        if(codeLen == 86) {
            log.info("카카오코드");
            reqURL = "https://kapi.kakao.com/v2/user/me";
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
                name = properties.getAsJsonObject().get("nickname").getAsString();

                log.info("name : " + name);

            } catch (IOException e) {
                e.printStackTrace();
            }

        // Naver UserInfo
        } else if(codeLen == 18) {
            reqURL = "https://openapi.naver.com/v1/nid/me";
            String header = "Bearer " + access_Token;

            try {
                URL url = new URL(reqURL);
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
            } catch (Exception e) {
                System.out.println(e);
            }


        // Google UserInfo
        } else if(codeLen == 73) {
            reqURL =  "https://www.googleapis.com/userinfo/v2/me?access_token=" + access_Token;
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


        }

        return name;
    }

}
