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
            width: 237px;
            margin: 50px;
        }
        #exampleInputPassword1 {
            margin-bottom: 50px;
        }
        .kakao_btn, .naver_btn, .google_btn{
            height: 50px;
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
        <div onclick="onLogin('kakao')">
            <a id="kakao_link" href="">
                <img class="kakao_btn" src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Ft1.daumcdn.net%2Fcfile%2Ftistory%2F99BEE8465C3D7D1214"/>
            </a>
        </div>
        <%-- Naver Login--%>
        <div onclick="onLogin('naver')">
            <a id="naver_link" href="">
                <img class="naver_btn" src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Ft1.daumcdn.net%2Fcfile%2Ftistory%2F99580C465C3D7D130C"/>
            </a>
        </div>
        <%-- Google Login--%>
        <div onclick="onLogin('google')">
            <a id="google_link" href="">
                <img class="google_btn" src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Ft1.daumcdn.net%2Fcfile%2Ftistory%2F998689465C3D7D1217"/>
            </a>
        </div>
        <script type="text/javascript">
            function onLogin(server) {
                let clientId = "";  //애플리케이션 클라이언트 아이디값";
                let redirectURI = "http://localhost:8080/IntegrationLogin";   // redirectURI
                let apiURL = "";
                if (server == "kakao") {
                    clientId = "2270f6337814fd5b2aa1f569bb282d8e";
                    apiURL = "https://kauth.kakao.com/oauth/authorize"
                        + "?client_id=" + clientId
                        + "&redirect_uri=" + redirectURI
                        + "&response_type=code";
                    document.getElementById("kakao_link").href = apiURL;
                } else if (server == "naver") {
                    // Navar Login을 위해 getSecureRandom 함수 값이 필요함
                    let state = getSecureRandom();
                    clientId = "8Z037cpOMLJbG8tl0BSu";
                    apiURL = "https://nid.naver.com/oauth2.0/authorize?response_type=code"
                        + "&client_id=" + clientId
                        + "&redirect_uri=" + redirectURI
                        + "&state=" + state;
                    document.getElementById("naver_link").href = apiURL;
                    // session에 state 값을 저장
                    sessionStorage.setItem("state", state);
                } else if (server == "google") {
                    clientId = "175958294391-mhl3hcs6a4v773jnvf294d00vvqtnn2h.apps.googleusercontent.com";
                    let scope = "https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email";
                    apiURL = "https://accounts.google.com/o/oauth2/v2/auth"
                        + "?client_id=" + clientId
                        + "&redirect_uri=" + redirectURI
                        + "&scope=" + scope
                        + "&response_type=code";
                    document.getElementById("google_link").href = apiURL;
                }
            }
            // SecureRandom 함수
            function getSecureRandom() {
                // allocate space for four 32-bit numbers
                const randoms = new Uint32Array(4);
                // get random values
                window.crypto.getRandomValues(randoms);
                // convert each number to string in base 32, then join together
                return Array.from(randoms).map(elem => elem.toString()).join("");
            }
        </script>
    </form>
</div>
</body>
</html>