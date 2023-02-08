<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <style>

  </style>
  <title>Insert title here</title>
  <%-- api에서 받아온 값을 FrontSample.jsp로 넘긴다. --%>
  <%
    String inputYn = request.getParameter("inputYn");
    String addrDetail = request.getParameter("addrDetail");
    String roadAddrPart1 = request.getParameter("roadAddrPart1");
    String roadAddrPart2 = request.getParameter("roadAddrPart2");
    String zipNo = request.getParameter("zipNo");
  %>
</head>
<script language="javascript">
  function init(){
    var url = location.href;
    // 발급받은 승인키
    var confmKey = "devU01TX0FVVEgyMDIzMDIwMTE1MDYwMDExMzQ2Nzk=";
    var resultType = "4"; // 도로명주소 검색결과 화면 출력유형, 1 : 도로명, 2 : 도로명+지번, 3 : 도로명+상세건물명, 4 : 도로명+지번+상세건물명
    var inputYn= "<%=inputYn%>";

    // FrontSample.jsp에 input 값이 없으면(초기)
    if(inputYn != "Y"){
      document.form.confmKey.value = confmKey;
      document.form.returnUrl.value = url;
      document.form.resultType.value = resultType;
      document.form.action="https://business.juso.go.kr/addrlink/addrLinkUrl.do"; // 인터넷망
      document.form.submit();
    }else{
      // opener 객체는 자기 자신을 연 기존 창의 window 객체를 참조
      // opener 객체를 활용하여 부모창과 자식창의 텍스트 데이터를 교환
      opener.jusoCallBack("<%=addrDetail%>","<%=roadAddrPart1%>","<%=roadAddrPart2%>","<%=zipNo%>");
      window.close();
    }
  }
</script>
<body onload="init();">
<form id="form" name="form" method="post">
  <input type="hidden" id="confmKey" name="confmKey" value=""/>
  <input type="hidden" id="returnUrl" name="returnUrl" value=""/>
  <input type="hidden" id="resultType" name="resultType" value=""/>
</form>
</body>
</html>