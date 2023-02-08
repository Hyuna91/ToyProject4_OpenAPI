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
    <style>
        body {
            margin: 0 auto;
        }
        #address-box {
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
        <form name="form" id="form" method="post">
            <h1>주소 API</h1>

            <label class="form-label mt-4">우편번호</label>
            <div class="form-group">
                <div class="input-group mb-3">
                    <input type="hidden" id="confmKey" name="confmKey" value=""  >
                    <input type="text" class="form-control" id="zipNo" name="zipNo" readonly>
                    <button class="btn btn-primary" type="button" id="button-addon2" value="주소검색" onclick="goPopup()">주소 검색</button>
                </div>
                <div class="form-group">
                    <label class="col-form-label mt-4" for="roadAddrPart1">도로명주소</label>
                    <input type="text" class="form-control" id="roadAddrPart1" >
                </div>
                <div class="form-group">
                    <label class="col-form-label mt-4" for="detail">상세주소</label>
                    <div id="detail">
                        <input type="text" class="form-control" id="addrDetail"  style="width:47%">
                        <input type="text" class="form-control" id="roadAddrPart2" style="width:47%">
                    </div>
                </div>
            </div>

            <%-- Map 출력 영역 --%>
            <div id="map" style="width:100%;height:350px;"></div>
        </form>
    </div>

    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=3cbe68a72f34ab56bdfdae359e07be4c&libraries=services"></script>
    <script>

        // 주소 검색 Button 클릭 시 PopUp 호출
        function goPopup(){
            // HomeController의 /jusopopup -> jusopopup.jsp를 open
            // 호출된 페이지(jusopopup.jsp)에서 실제 주소검색URL(https://business.juso.go.kr/addrlink/addrLinkUrl.do)를 호출하게 됩니다.
            // window.open("/jusoPopup", "pop", "width=570, height=420, scrollbars=yes, resizable=yes");
            window.open("jusoPopup", "pop", "width=570, height=420, scrollbars=yes, resizable=yes");
        }

        // Popup창에서 주소 값을 받아오는 메서드
        function jusoCallBack(addrDetail, roadAddrPart1, roadAddrPart2, zipNo){
            // 팝업페이지에서 주소입력한 정보를 받아서, 현 페이지에 정보를 등록합니다.
            document.form.roadAddrPart1.value = roadAddrPart1;
            document.form.roadAddrPart2.value = roadAddrPart2;
            document.form.addrDetail.value = addrDetail;
            document.form.zipNo.value = zipNo;

            // 주소 값을 받아온 후 Kakao 화면을 그리는 메서드 호출
            onMap();
        }

        function onMap() {
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
            let getAdrress = document.getElementById("roadAddrPart1").value;

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