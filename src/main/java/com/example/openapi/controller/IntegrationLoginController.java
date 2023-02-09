package com.example.openapi.controller;

import com.example.openapi.service.IntegrationLoginService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;

@Controller
@Slf4j
public class IntegrationLoginController {

    @Autowired
    private IntegrationLoginService ils;

    // localhost:8080으로 입장 시 login.jsp 화면으로 이동
    @RequestMapping(value = "/")
    public String login() {
        return "/itgLogin";
    }

    // 공통으로 code를 받아올 수 있는지 확인 - 가능
    @RequestMapping(value = "/IntegrationLogin")
//    public String integrationLogin(@RequestParam(value = "code", required = false) String code, HttpServletRequest request, Model model) throws Exception{
    public String integrationLogin(HttpServletRequest request, Model model) throws Exception {
        String state = request.getParameter("state");
        String code = request.getParameter("code");
        String name = "";
        
        // 구분을 위해 requestURL 받아오기 - 실패
        // 각 서버마다 code의 글자 길이가 다름 - KaKao(86자리)/Naver(18자리)/Google(73자리)
        int codeLen = code.length();

        // Login을 통해 획득한 authorize Code를 access Token를 받아오기 위해 보낸다.
        String access_Token = ils.getAccessToken(code, state);
        log.info(access_Token);

        // Login한 Server 표시
        if (codeLen == 86) {
            name = "카카오 - " + (String)ils.getUserInfo(code, access_Token);
        } else if (codeLen == 18) {
            name = "네이버 - " + (String)ils.getUserInfo(code, access_Token);
        } else if (codeLen == 73) {
            name = "구글 - " + (String)ils.getUserInfo(code, access_Token);
        }

        model.addAttribute("name", name);

        return "/BackSampleXml";
    }


}
