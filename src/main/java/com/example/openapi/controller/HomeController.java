package com.example.openapi.controller;

import java.io.*;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ch.qos.logback.core.util.FileUtil;
import lombok.extern.slf4j.Slf4j;
import org.apache.tomcat.util.http.fileupload.FileItem;
import org.apache.tomcat.util.http.fileupload.disk.DiskFileItemFactory;
import org.apache.tomcat.util.http.fileupload.servlet.ServletFileUpload;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.multipart.MultipartFile;
import org.w3c.dom.*;
import org.xml.sax.InputSource;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

@Controller
@Slf4j
public class HomeController {
    //  화면단 처리(JSON)
    @RequestMapping(value = "/front")
    public String frontHome() {
        return "FrontSample";
    }

    @RequestMapping(value = "/jusoPopup")
    public String jusoPopup() {
        return "jusoPopup";
    }


    // 서버단 처리(JSON)
    @RequestMapping(value = "/back")
    public String backHome() {
        return "BackSample";
    }

    @RequestMapping(value = "/getAddrApi")
    public void getAddrApi(HttpServletRequest req, HttpServletResponse response) throws Exception {
        // BackSample.jsp에서 받아온 req로 요청변수 설정
        String currentPage = req.getParameter("currentPage");    //요청 변수 설정 (현재 페이지. currentPage : n > 0)
        String countPerPage = req.getParameter("countPerPage");  //요청 변수 설정 (페이지당 출력 개수. countPerPage 범위 : 0 < n <= 100)
        String resultType = req.getParameter("resultType");      //요청 변수 설정 (검색결과형식 설정, json)
        String confmKey = req.getParameter("confmKey");          //요청 변수 설정 (승인키)
        String keyword = req.getParameter("keyword");            //요청 변수 설정 (키워드)

        // OPEN API 호출 URL 정보 설정
        String apiUrl = "https://business.juso.go.kr/addrlink/addrLinkApi.do?currentPage=" +
                currentPage +
                "&countPerPage=" +
                countPerPage +
                "&keyword=" +
                URLEncoder.encode(keyword, "UTF-8") +
                "&confmKey=" +
                confmKey +
                "&resultType=" +
                resultType;

        // new URL로 URL을 생성
        URL url = new URL(apiUrl);
        log.info(String.valueOf(url));

        // openStream()을 호출하면 사이트의 정보를 읽어들일 수 있다.
        BufferedReader br = new BufferedReader(new InputStreamReader(url.openStream(), "UTF-8"));
        StringBuffer sb = new StringBuffer();
        String tempStr = null;

        while (true) {
            // 사이트에서 읽어드린 정보는 br(Object)를 tempStr(String)에 담는다.
            tempStr = br.readLine();
            if (tempStr == null) break;
            // append를 사용하여 tempStr값을 sb(StringBuffer)에 담는다.
            sb.append(tempStr);                        // 응답결과 JSON 저장
        }
        br.close();

        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/xml");
        response.getWriter().write(sb.toString());         // 응답결과 반환
    }

    // 서버단 처리(XML)
    @RequestMapping(value = "/backxml")
    public String backXmlHome() {
        return "BackSampleXml";
    }

    @RequestMapping(value = "/getAddrApiXml")
    public void getAddrApiXml(HttpServletRequest req, HttpServletResponse response) throws Exception {
        // 요청변수 설정
        String currentPage = req.getParameter("currentPage");    //요청 변수 설정 (현재 페이지. currentPage : n > 0)
        String countPerPage = req.getParameter("countPerPage");  //요청 변수 설정 (페이지당 출력 개수. countPerPage 범위 : 0 < n <= 100)
        String confmKey = req.getParameter("confmKey");          //요청 변수 설정 (승인키)
        String keyword = req.getParameter("keyword");            //요청 변수 설정 (키워드)
        // OPEN API 호출 URL 정보 설정
        String apiUrl = "https://business.juso.go.kr/addrlink/addrLinkApi.do?currentPage=" + currentPage + "&countPerPage=" + countPerPage + "&keyword=" + URLEncoder.encode(keyword, "UTF-8") + "&confmKey=" + confmKey;

        DocumentBuilderFactory dbFactoty = DocumentBuilderFactory.newInstance();
        DocumentBuilder dBuilder = dbFactoty.newDocumentBuilder();
        Document doc = dBuilder.parse(apiUrl);
        StringBuffer sb = new StringBuffer();

        log.info(String.valueOf(doc));  // [#document: null]

        doc.getDocumentElement().normalize();
        // root(최상위) tag 찾기
        log.info("Root element :" + doc.getDocumentElement().getNodeName());    // Root element :results

        // 파싱할 tag = <juso>
        // nList에 <juso>태그가 하나씩 담기게 되고 nList.getLenght()를 통해 리스트의 수를 확인할 수 있다.
        NodeList nList = doc.getElementsByTagName("juso");
        System.out.println("파싱할 리스트 수 : " + nList.getLength());

        // 위에 담긴 list를 반복문을 이용하여 출력한다.
        // getTextContent() : 전체 정보
        // getTagValue("tag", element) : 입력한 tag 정보
        for (int temp = 0; temp < nList.getLength(); temp++) {
            Node nNode = nList.item(temp);
            if (nNode.getNodeType() == Node.ELEMENT_NODE) {

                Element eElement = (Element) nNode;
                // getTextContent() : 전체 정보
                // System.out.println(eElement.getTextContent());

                sb.append("<label class=\"col-form-label mt-4\" for=\"detail\" >주소</label>");
                sb.append("<p onclick=\"onMap(this)\">" + getTagValue("roadAddr", eElement) + "</p>");
                sb.append("<label class=\"col-form-label mt-4\" for=\"detail\">우편번호</label>");
                sb.append("<p>" + getTagValue("zipNo", eElement) + "</p>");

            }   // for end
        }   // if end

        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain");
        response.getWriter().write(String.valueOf(sb));
    }

    private static String getTagValue(String tag, Element eElement) {
        NodeList nlList = eElement.getElementsByTagName(tag).item(0).getChildNodes();
        Node nValue = (Node) nlList.item(0);
        if (nValue == null)
            return null;
        return nValue.getNodeValue();
    }

    // 화면단 처리(XML)
    @RequestMapping(value = "/frontxml")
    public String frontXmlHome() {
        return "FrontSampleXml";
    }

    @RequestMapping(value = "/getAddrApiXmlFront")
    public void getAddrApiXmlFront(HttpServletRequest req, HttpServletResponse response) throws Exception {
        // 요청변수 설정
        String currentPage = req.getParameter("currentPage");    //요청 변수 설정 (현재 페이지. currentPage : n > 0)
        String countPerPage = req.getParameter("countPerPage");  //요청 변수 설정 (페이지당 출력 개수. countPerPage 범위 : 0 < n <= 100)
        String confmKey = req.getParameter("confmKey");          //요청 변수 설정 (승인키)
        String keyword = req.getParameter("keyword");            //요청 변수 설정 (키워드)
        // OPEN API 호출 URL 정보 설정
        String apiUrl = "https://business.juso.go.kr/addrlink/addrLinkApi.do?currentPage=" + currentPage + "&countPerPage=" + countPerPage + "&keyword=" + URLEncoder.encode(keyword, "UTF-8") + "&confmKey=" + confmKey;
        URL url = new URL(apiUrl);

        BufferedReader br = new BufferedReader(new InputStreamReader(url.openStream(), "UTF-8"));
        StringBuffer sb = new StringBuffer();
        String tempStr = null;

        while (true) {
            tempStr = br.readLine();
            if (tempStr == null) break;
            sb.append(tempStr);                        // 응답결과 XML 저장
        }
        br.close();

        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/xml");
        response.getWriter().write(sb.toString());         // 응답결과 반환
    }

    // xml 파싱 후 jsp 파일로 전송
    @RequestMapping(value = "/backXmlJsp")
    public String backXmlBack() {
        return "BackSampleXmlJsp";
    }

    @RequestMapping(value = "/getAddrApiXmlJsp")
    public void getAddrApiXmlJsp(HttpServletRequest req, HttpServletResponse res) throws Exception {
        // 요청변수 설정
        String currentPage = req.getParameter("currentPage");
        String countPerPage = req.getParameter("countPerPage");
        String confmKey = req.getParameter("confmKey");
        String keyword = req.getParameter("keyword");
        // OPEN API 호출 URL 정보 설정
        String api = "https://business.juso.go.kr/addrlink/addrLinkApi.do?currentPage=" +
                currentPage +
                "&countPerPage=" +
                countPerPage +
                "&keyword=" +
                URLEncoder.encode(keyword, "UTF-8") +
                "&confmKey=" +
                confmKey;

        // XML 파싱을 위한
        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
        DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
        Document doc = dBuilder.parse(api);
//        StringBuffer sb = new StringBuffer();

        doc.getDocumentElement().normalize();

        NodeList nList = doc.getElementsByTagName("juso");

        // jsp 파일 가져오기
        BufferedReader reader = null;
        // Youin PC
//        String filePath = "C:\\dev\\ToyProject4_OpenAPI\\src\\main\\webapp\\WEB-INF\\views\\outFile.jsp";
        // Home PC
        String filePath = "C:\\Users\\장현아\\IdeaProjects\\ToyProject4_OpenAPI\\src\\main\\webapp\\WEB-INF\\views\\outFile.jsp";
        String outText = "";

        try {
            reader = new BufferedReader(new FileReader(filePath));
            for (int temp = 0; temp < nList.getLength(); temp++) {
                // Node를 nList.getLength()만큼 만든다.
                Node nNode = nList.item(temp);
                // nNode의 NodeType(1=요소노드) 이 요소노드(Node.ELEMENT_NODE == 1)이면
                if (nNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element eElement = (Element) nNode;
                    outText += "<label class=\"col-form-label mt-4\" >주소</label>"+"\n";
                    outText += "<p onclick=\"onMap(this)\">" + getTagValue("roadAddr", eElement) + "</p>"+"\n";
                    outText += "<label class=\"col-form-label mt-4\">우편번호</label>"+"\n";
                    outText += "<p>" + getTagValue("zipNo", eElement) + "</p>"+"\n";
                }
            }
        } catch (FileNotFoundException fnfe) {
            log.info("파일이 존재하지 않습니다.");
        } finally {
            try {
                reader.close();
            } catch (Exception e) {
                log.info("FileNotFoundException error");
            }
        }
        log.info("outText : " + outText);

        // 받아온 데이터로 outFile.jsp에 덮어쓴다.
        try {
            BufferedWriter bfWrite = new BufferedWriter(new FileWriter(filePath));
            bfWrite.write(outText, 0, outText.length());
            bfWrite.flush();
            bfWrite.close();
        } catch (Exception e) {

        }

        res.setCharacterEncoding("UTF-8");
        res.setContentType("multipart/form-data");

        // outFile.jsp 전송
        FileInputStream file = new FileInputStream(filePath);
        BufferedInputStream bis = new BufferedInputStream(file);
        log.info(bis.toString());

        bis.close();
    }


}