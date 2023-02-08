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
    <script src="//developers.kakao.com/sdk/js/kakao.min.js"></script>
    <script type="text/javascript" src="https://static.nid.naver.com/js/naverLogin_implicit-1.0.3.js" charset="utf-8"></script>
    <script type="text/javascript" src="Login.js"></script>
    <style>
        body {
            margin: 0 auto;
        }
        #login-box {
            width: 30%;
            margin: 50px;
        }
        #exampleInputPassword1 {
            margin-bottom: 50px;
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

            <%-- KaKao Login--%>
            <a id="kakao-login-btn"></a>

            <%-- Naver Login--%>
            <div id="naver_id_login"></div>


        </form>
    </div>
    <script src="https://developers.kakao.com/sdk/js/kakao.js"></script>
    <script type="text/javascript">
        <%-- Naver Login --%>
        const CLIENT_ID = "8Z037cpOMLJbG8tl0BSu";
        const CALLBACK_URL = "http://localhost:8080/AfterloginNaver";
        const SERVICE_URL = "http://localhost:8080"
        var naver_id_login = new naver_id_login(CLIENT_ID, CALLBACK_URL);
        var state = naver_id_login.getUniqState();
        naver_id_login.setButton("white", 2,40);
        naver_id_login.setDomain(SERVICE_URL);
        naver_id_login.setState(state);
        naver_id_login.setPopup();
        naver_id_login.init_naver_id_login();

        <%-- KaKoa Login --%>
        const REST_API_KEY = "2270f6337814fd5b2aa1f569bb282d8e";
        const JS_API_KEY = "3cbe68a72f34ab56bdfdae359e07be4c";
        const REDIRECT_URI = "https://localhost:8080";
        <%--const url = `https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=${REST_API_KEY}&redirect_uri=${REDIRECT_URI}`;--%>
        const url = `https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=2270f6337814fd5b2aa1f569bb282d8e&redirect_uri=https://localhost:8080`;
        // 사용할 앱의 JavaScript 키를 설정해 주세요.
        Kakao.init(JS_API_KEY);
        // 카카오 로그인 버튼을 생성합니다.

        Kakao.Auth.createLoginButton({
            container: '#kakao-login-btn',
            success: function (authObj) {
                // alert("성공?");
                // console.log(JSON.stringify(authObj));
            },
            fail: function (err) {
                alert("실패?");
                alert(JSON.stringify(err));
            }
        });
    </script>
</body>
</html>