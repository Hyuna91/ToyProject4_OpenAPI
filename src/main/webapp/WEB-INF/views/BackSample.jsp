<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
        #map-box {
            width: 30%;
            margin: 50px;
        }
        #detail {
            display: flex;
            justify-content: space-between;
        }
    </style>
    <title>주소 입력 API</title>
</head>
<body>
    <div class="form-group" id="address-box">
        <form name="form" id="form"method="post">
            <h1>주소 API</h1>

            <input type="text" name="currentPage" style="display:none" value="1" /> <!-- 요청 변수 설정 (현재 페이지. currentPage : n > 0) -->
            <input type="text" name="countPerPage" style="display:none" value="5"/><!-- 요청 변수 설정 (페이지당 출력 개수. countPerPage 범위 : 0 < n <= 100) -->
            <input type="text" name="resultType" style="display:none" value="json"/> <!-- 요청 변수 설정 (검색결과형식 설정, json) -->
            <input type="text" name="confmKey" id="confmKey" style="width:250px;display:none" value="devU01TX0FVVEgyMDIzMDIwMTE1NTY1NjExMzQ2ODY="/><!-- 요청 변수 설정 (승인키) -->

            <div id="detail">
                <input type="text" class="form-control" name="keyword" value="" style="margin-right: 20px" onkeydown="enterSearch();"/><!-- 요청 변수 설정 (키워드) -->
                <input type="button" class="btn btn-primary" onClick="getAddrLoc();" value="주소검색하기" />
            </div>
            <!-- 검색 결과 리스트 출력 영역 -->
            <div id="list"></div>
        </form>
    </div>
    <%-- Map 출력 영역 --%>
    <div class="form-group" id="map-box">
        <div id="map" style="width:100%;height:350px;margin-top: 100px;"></div>
    </div>

    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=3cbe68a72f34ab56bdfdae359e07be4c&libraries=services"></script>
    <script>
        // 주소검색하기 Button 클릭
        function getAddrLoc(){
            // API 호출 전 검색어 체크
            if (!checkSearchedWord(document.form.keyword)) { return true }

            $.ajax({
            url :"/getAddrApi",
            type:"post",
            data:$("#form").serialize(),
            dataType:"json",
                success:function(jsonStr){
                    $("#list").html("");
                    var errCode = jsonStr.results.common.errorCode;
                    var errDesc = jsonStr.results.common.errorMessage;
                    if(errCode != "0"){
                        alert(errCode+"="+errDesc);
                    }else{
                        if(jsonStr != null){
                            makeListJson(jsonStr);
                        }
                    }
                },
                error: function(xhr,status, error){
                    alert("에러발생");
                }
            });
        }

        // Result 값을 Html 형태로 변경
        function makeListJson(jsonStr){
            var htmlStr = "";
            // var htmlPage = "";

            // $(jsonStr.results.juso).each(function(index){
            // htmlStr += `<div><label class="col-form-label mt-4" for="detail" >No.`+ parseInt(index+1) +`</label></div>`;
            // htmlStr += `<label class="col-form-label mt-4" for="detail" style="margin-top: 0px">주소</label>`;
            // htmlStr += `<p id="mapAddress" onclick="onMap(this)">`+this.roadAddr+"</p>";
            // htmlStr += `<label class="col-form-label mt-4" for="detail">우편번호</label>`;
            // htmlStr += "<p>"+this.zipNo+"</p>";
            // htmlStr += "<hr>";
            // });

            for (let i = 0; i < jsonStr.results.juso.length; i++) {
            // for (let i = (page - 1) * itemsInAPage; i < page * itemsInAPage; i++) {
                // console.log(i)
                htmlStr += `<div><label class="col-form-label mt-4" for="detail" >No.`+ parseInt(i+1) +`</label></div>`;
                htmlStr += `<label class="col-form-label mt-4" for="detail" style="margin-top: 0px">주소</label>`;
                htmlStr += `<p id="mapAddress" onclick="onMap(this)">`+jsonStr.results.juso[i].roadAddr+"</p>";
                htmlStr += `<label class="col-form-label mt-4" for="detail">우편번호</label>`;
                htmlStr += "<p>"+jsonStr.results.juso[i].zipNo+"</p>";
                htmlStr += "<hr>";
            }

            // Paging
            // const page = 1;   // 시작 페이지
            // const itemsInAPage = 5;   // 화면에 나타날 페이지 개수

            // htmlPage += `<div>
            //                 <ul class="pagination pagination-sm">
            //                     <li class="page-item disabled">
            //                         <a class="page-link" href="#">&laquo;</a>
            //                     </li>
            //                     <li class="page-item active">
            //                         <a class="page-link" href="#">1</a>
            //                     </li>
            //                     <li class="page-item">
            //                         <a class="page-link" href="#" onclick="">2</a>
            //                     </li>
            //                     <li class="page-item">
            //                         <a class="page-link" href="#">3</a>
            //                     </li>
            //                     <li class="page-item">
            //                         <a class="page-link" href="#">4</a>
            //                     </li>
            //                     <li class="page-item">
            //                         <a class="page-link" href="#">5</a>
            //                     </li>
            //                     <li class="page-item">
            //                         <a class="page-link" href="#">&raquo;</a>
            //                     </li>
            //                 </ul>
            //             </div>`

            $("#list").html(htmlStr);
            // $("#page").html(htmlPage);
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

        // Enter로 Search되도록 하는 메서드
        function enterSearch() {
            var evt_code = (window.netscape) ? ev.which : event.keyCode;
            if (evt_code == 13) {
                event.keyCode = 0;
                getAddrLoc();
            }
        }

        // 카카오 지도 메서드
        function onMap(jsonStr) {
            // console.log(jsonStr)
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
            // let getAdrress = jsonStr.results.juso[0].roadAddrPart1;
            // console.log(jsonStr.innerText);
            let getAdrress = jsonStr.innerText;
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

        //페이지 이동
        function goPage(pageNum){
            document.form.currentPage.value=pageNum;
            getAddr();
        }
        // json타입 페이지 처리 (주소정보 리스트 makeListJson(jsonStr); 다음에서 호출)
        /*
        *  json타입으로 페이지 처리시 수정
        *  function pageMake(jsonStr){
        *  	var total = jsonStr.results.common.totalCount; // 총건수
        */

        // xml타입 페이지 처리 (주소정보 리스트 makeList(xmlData); 다음에서 호출)
        function pageMake(xmlStr){
            var total = $(xmlStr).find("totalCount").text(); // 총건수
            var pageNum = document.form.currentPage.value;// 현재페이지
            var paggingStr = "";
            if(total < 1){
            }else{
                var PAGEBLOCK=parseInt(document.form.countPerPage.value);
                var pageSize=document.form.countPerPage.value;
                var totalPages = Math.floor((total-1)/pageSize) + 1;
                var firstPage = Math.floor((pageNum-1)/PAGEBLOCK) * PAGEBLOCK + 1;
                if( firstPage <= 0 ) firstPage = 1;
                var lastPage = firstPage-1 + PAGEBLOCK;
                if( lastPage > totalPages ) lastPage = totalPages;
                var nextPage = lastPage+1 ;
                var prePage = firstPage-5 ;
                if( firstPage > PAGEBLOCK ){
                    paggingStr +=  "<a href='javascript:goPage("+prePage+");'>◁</a>  " ;
                }
                for( i=firstPage; i<=lastPage; i++ ){
                    if( pageNum == i )
                        paggingStr += "<a style='font-weight:bold;color:blue;font-size:15px;' href='javascript:goPage("+i+");'>" + i + "</a>  ";
                    else
                        paggingStr += "<a href='javascript:goPage("+i+");'>" + i + "</a>  ";
                }
                if( lastPage < totalPages ){
                    paggingStr +=  "<a href='javascript:goPage("+nextPage+");'>▷</a>";
                }
                $("#pageApi").html(paggingStr);
            }
        }
    </script>
</body>
</html>