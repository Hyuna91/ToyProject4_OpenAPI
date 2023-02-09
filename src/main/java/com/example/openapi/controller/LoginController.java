package com.example.openapi.controller;

import com.example.openapi.service.LoginService;
import com.google.gson.JsonElement;
import com.google.gson.JsonParser;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;

@Controller
@Slf4j
public class LoginController {

    @Autowired
    private LoginService ls;

    // Login 첫 화면
    @RequestMapping(value = "/login")
    public String login() {
        return "/login"; };


    // Kakao Login
    @RequestMapping(value = "/AfterloginKakao")
    public String afterLoginKakao(@RequestParam(value = "code", required = false) String code, Model model) throws Exception{
        // 인증 코드 받아오기
        log.info("code : " + code); // xAsb0VDasYcz2GywHjYtHiHQcmM8sbZsngi59I-Y7cWwtEh0M0WcolM1auQzXKK7o3Dnhgo9cxcAAAGGJVdW1Q

        // code를 보내서 access_Token 얻기
        String access_Token = ls.getAccessToken(code);

        HashMap<String, Object> userInfo = ls.getUserInfo(access_Token);

        String name = "카카오 - " + (String) userInfo.get("name");

        model.addAttribute("name", name);

        return "/BackSampleXml"; };

    // Naver Login
    @RequestMapping(value = "/AfterloginNaver")
    public String afterLoginNaver(HttpServletRequest request, Model model) throws Exception {
        String clientId = "8Z037cpOMLJbG8tl0BSu";//애플리케이션 클라이언트 아이디값";
        String clientSecret = "Ku0kyXmbCc";//애플리케이션 클라이언트 시크릿값";
        String code = request.getParameter("code");
        String state = request.getParameter("state");
        String name = "";

        String redirectURI = URLEncoder.encode("http://localhost:8080/AfterloginNaver", "UTF-8");
        String apiURL;
        apiURL = "https://nid.naver.com/oauth2.0/token?grant_type=authorization_code&";
        apiURL += "client_id=" + clientId;
        apiURL += "&client_secret=" + clientSecret;
        apiURL += "&redirect_uri=" + redirectURI;
        apiURL += "&code=" + code;
        apiURL += "&state=" + state;
        String access_token = "";
        String refresh_token = "";
        try {
            URL url = new URL(apiURL);
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


            access_token = element.getAsJsonObject().get("access_token").getAsString();
            refresh_token = element.getAsJsonObject().get("refresh_token").getAsString();

            log.info("access_token : " + access_token);
            log.info("refresh_token : " + refresh_token);

            br.close();
            if(responseCode==200) {
                System.out.println(res.toString());
            }
        } catch (Exception e) {
            System.out.println(e);
            return "/afterLogin";
        }

        name = "네이버 - " + (String)ls.getUserInfoNaver(access_token);
        model.addAttribute("name", name);

        return "/BackSampleXml";
    }

    // Google Login
    @RequestMapping(value = "/AfterloginGoogle")
    public String afterLoginGoogle(HttpServletRequest request, Model model) throws Exception{
        // Authorization code 받기
        String getQueryString = request.getQueryString();
        int index = getQueryString.indexOf("code=") + 5;
        int lastIndex = getQueryString.indexOf("&scope");
        String code = getQueryString.substring(index,lastIndex);
        log.info("getQueryString : " + getQueryString);
        log.info("code : " + code);
        String clientId = "175958294391-mhl3hcs6a4v773jnvf294d00vvqtnn2h.apps.googleusercontent.com";
        String clientSecret = "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";
        String redirectUrl = "http://localhost:8080/AfterloginGoogle";

        String access_Token = ls.getGoogleToken(code);

        String name1 = ls.getGoogleUserInfo(access_Token);
        String name = "구글 - " + name1;
//        String accessToken = ls.getGoogleToken(code);
//        log.info("accessToken : " + access_Token);
        log.info("name : " + name);

        model.addAttribute("name", name);
        return "/BackSampleXml";
//        return "redirect:/BackSampleXml";
    }
}
