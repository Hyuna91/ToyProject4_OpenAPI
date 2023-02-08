<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.math.BigInteger" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- First include jquery js -->
    <script src="//code.jquery.com/jquery-1.12.0.min.js"></script>
    <script src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css">
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@5.2.3/dist/minty/bootstrap.min.css">
    <%-- KaKao Login --%>
    <script src="//developers.kakao.com/sdk/js/kakao.min.js"></script>
    <%-- Naver Login --%>
    <script type="text/javascript" src="https://static.nid.naver.com/js/naverLogin_implicit-1.0.3.js" charset="utf-8"></script>
    <%-- Google Login --%>
    <script src="https://accounts.google.com/gsi/client" async defer></script>

    <style>
        body {
            margin: 0 auto;
        }
        #login-box {
            /*width: 13%;*/
            width: 237px;

            margin: 50px;
        }
        #exampleInputPassword1 {
            margin-bottom: 50px;
        }
        .kakao_btn{
            background-image: url("https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Ft1.daumcdn.net%2Fcfile%2Ftistory%2F99BEE8465C3D7D1214");
            background-repeat: no-repeat;
            background-size : cover;
            margin: 10px auto;
            /*margin: 10px 65px;*/
            /* padding: -10px; */
            width: 237px;
            height: 50px;
            display: inline-block;
        }
        .naver_btn{
            /*margin: 10px auto;*/
            /* padding: -10px; */
            color: transparent;
            width: 300px;
            height: 60px;
        }
    </style>
    <title>Login API</title>
</head>
<body>
<div class="form-group" id="login-box">
    <form name="form" id="form" method="post">
        <h1>Login</h1>

        <div class="form-group">
            <label for="exampleInputEmail1" class="form-label mt-4">Email address</label>
            <input type="email" class="form-control" id="exampleInputEmail1" aria-describedby="emailHelp" placeholder="Enter email" disabled>
            <small id="emailHelp" class="form-text text-muted">We'll never share your email with anyone else.</small>
        </div>
        <div class="form-group">
            <label for="exampleInputPassword1" class="form-label mt-4">Password</label>
            <input type="password" class="form-control" id="exampleInputPassword1" placeholder="Password" disabled>
        </div>

        <h4>------------SNS LogIn------------</h4>

        <%-- KaKao Login--%>
        <div>
            <a href="https://kauth.kakao.com/oauth/authorize?client_id=2270f6337814fd5b2aa1f569bb282d8e&redirect_uri=http://localhost:8080/AfterloginKakao&response_type=code">
                <div class="kakao_btn"></div>
            </a>
        </div>

        <%-- Naver Login--%>
        <%
            String clientId = "8Z037cpOMLJbG8tl0BSu";//애플리케이션 클라이언트 아이디값";
            String redirectURI = URLEncoder.encode("http://localhost:8080/AfterloginNaver", "UTF-8");
            SecureRandom random = new SecureRandom();
            String state = new BigInteger(130, random).toString();
            String apiURL = "https://nid.naver.com/oauth2.0/authorize?response_type=code"
                    + "&client_id=" + clientId
                    + "&redirect_uri=" + redirectURI
                    + "&state=" + state;
            session.setAttribute("state", state);
//                System.out.println("state : " + state); // 255849927828952095556601748959154492328
        %>
        <div class="naver_btn">
            <a href="<%=apiURL%>"><img height="50" src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Ft1.daumcdn.net%2Fcfile%2Ftistory%2F99580C465C3D7D130C"/></a>
        </div>

        <%-- Google Login--%>
        <%
            String clientId_google = "175958294391-mhl3hcs6a4v773jnvf294d00vvqtnn2h.apps.googleusercontent.com";//애플리케이션 클라이언트 아이디값";
            String redirectUrl_google = "http://localhost:8080/AfterloginGoogle";//redirect Url";
            String scope_google = "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email";
            String apiURL_google;
            apiURL_google = "https://accounts.google.com/o/oauth2/v2/auth";
            apiURL_google += "?client_id=" + clientId_google;
            apiURL_google += "&redirect_uri=" + redirectUrl_google;
            apiURL_google += "&scope=" + scope_google;
            apiURL_google += "&response_type=code";
        %>
        <div class="google_btn">
            <a href="<%=apiURL_google%>"><img height="50" src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Ft1.daumcdn.net%2Fcfile%2Ftistory%2F998689465C3D7D1217"/></a>
        </div>
        <script src="https://accounts.google.com/gsi/client" async defer></script>
        <script>
            window.onload = function () {
                google.accounts.id.initialize({
                    client_id: '175958294391-mhl3hcs6a4v773jnvf294d00vvqtnn2h.apps.googleusercontent.com',
                    callback: "http://localhost:8080/AfterloginGoogle"
                });
                google.accounts.id.prompt();
            };
        </script>

    </form>
</div>
</body>
</html>