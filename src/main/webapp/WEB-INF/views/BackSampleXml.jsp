<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <script src="//code.jquery.com/jquery-1.12.0.min.js"></script>
    <script src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/css/bootstrap-theme.min.css">
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.2/js/bootstrap.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootswatch@5.2.3/dist/minty/bootstrap.min.css">
    <style>
        body {
            margin: 0 auto;
            display: flex;
        }
        #address-box {
            width: 30%;
            margin: 50px;
        }
        #detail {
            display: flex;
            justify-content: space-between;
        }
        #map-box {
            width: 30%;
            margin: 50px;
        }
        #loginUser {
            text-align: end;
        }
    </style>
    <title>주소 입력 API</title>

</head>
<body>

<div class="form-group" id="address-box">
    <form name="form" id="form"method="post">
        <h4 id="loginUser"><b style="color: mediumblue">${name}</b>님 로그인 완료</h4>
        <hr>
        <h1>주소 API</h1>

        <input type="text" name="currentPage" style="display:none" value="1" /> <!-- 요청 변수 설정 (현재 페이지. currentPage : n > 0) -->
        <input type="text" name="countPerPage" style="display:none" value="5"/><!-- 요청 변수 설정 (페이지당 출력 개수. countPerPage 범위 : 0 < n <= 100) -->
        <input type="text" name="confmKey" id="confmKey" style="width:250px;display:none" value="devU01TX0FVVEgyMDIzMDIwMTE1NTY1NjExMzQ2ODY="/><!-- 요청 변수 설정 (승인키) -->

        <div id="detail">
            <input type="text" class="form-control" name="keyword" value="" style="margin-right: 20px" onkeydown="enterSearch();"/><!-- 요청 변수 설정 (키워드) -->
            <input type="button" class="btn btn-primary" onClick="getAddrLoc();" value="주소검색하기" />
        </div>

        <!-- 검색 결과 리스트 출력 영역 -->
        <div id="list" ></div>
    </form>
</div>

<%-- Map 출력 영역 --%>
<div class="form-group" id="map-box">
    <div id="map" style="width:100%;height:350px;margin-top: 100px;"></div>
</div>

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=3cbe68a72f34ab56bdfdae359e07be4c&libraries=services"></script>
<script src="https://apis.google.com/js/platform.js" async defer></script>

<script>
    function getAddrLoc(){
        // 적용예 (api 호출 전에 검색어 체크)
        if (!checkSearchedWord(document.form.keyword)) { return true; }

        $.ajax({
            url :"getAddrApiXml",
            type:"post",
            data:$("#form").serialize(),
            dataType:"text",
            success:function(htmlStr){
                if(htmlStr != null){
                    makeList(htmlStr);
                }
            },
            error: function(xhr,status, error){
                alert("에러발생");
            }
        });
    }

    // Result 값을 Html 형태로 변경(값을 받아오는 방법이 JSON과 다름)
    function makeList(htmlStr){
        $("#list").html(htmlStr);
    }

    //특수문자, 특정문자열(sql예약어의 앞뒤공백포함) 제거
    function checkSearchedWord(obj){
        if(obj.value.length >0){
            //특수문자 제거
            var expText = /[%=><]/ ;
            if(expText.test(obj.value) == true){
                alert("특수문자를 입력 할수 없습니다.") ;
                obj.value = obj.value.split(expText).join("");
                return false;
            }

            //특정문자열(sql예약어의 앞뒤공백포함) 제거
            var sqlArray = new Array(
                //sql 예약어
                "OR", "SELECT", "INSERT", "DELETE", "UPDATE", "CREATE", "DROP", "EXEC",
                "UNION",  "FETCH", "DECLARE", "TRUNCATE"
            );

            var regex;
            for(var i=0; i<sqlArray.length; i++){
                regex = new RegExp( sqlArray[i] ,"gi") ;

                if (regex.test(obj.value) ) {
                    alert("\"" + sqlArray[i]+"\"와(과) 같은 특정문자로 검색할 수 없습니다.");
                    obj.value =obj.value.replace(regex, "");
                    return false;
                }
            }
        }
        return true ;
    }

    function enterSearch() {
        var evt_code = (window.netscape) ? ev.which : event.keyCode;
        if (evt_code == 13) {
            event.keyCode = 0;
            getAddrLoc();
        }
    }

    // 카카오 지도 메서드
    function onMap(xmlStr) {
        console.log(xmlStr)
        var mapContainer = document.getElementById('map'), // 지도를 표시할 div
            mapOption = {
                center: new kakao.maps.LatLng(33.450701, 126.570667), // 지도의 중심좌표
                level: 3 // 지도의 확대 레벨
            };

        // 지도를 생성합니다
        var map = new kakao.maps.Map(mapContainer, mapOption);

        // 주소-좌표 변환 객체를 생성합니다
        var geocoder = new kakao.maps.services.Geocoder();

        // 주소로 좌표를 검색합니다
        // let getAdrress = xmlStr.getElementsByTagName("roadAddrPart1")[0].textContent;
        let getAdrress = xmlStr.innerText;

        geocoder.addressSearch(getAdrress, function (result, status) {

            // 정상적으로 검색이 완료됐으면
            if (status === kakao.maps.services.Status.OK) {
                var coords = new kakao.maps.LatLng(result[0].y, result[0].x);

                // 결과값으로 받은 위치를 마커로 표시합니다
                var marker = new kakao.maps.Marker({
                    map: map,
                    position: coords
                });

                // 지도의 중심을 결과값으로 받은 위치로 이동시킵니다
                map.setCenter(coords);
            }
        });
    }
</script>
</body>
</html>