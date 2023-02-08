List
$(xmlStr).find("juso").each(function(){
htmlStr += `<label class="col-form-label mt-4" for="detail" >주소</label>`;
htmlStr += `<p onclick="onMap(this)">`+$(this).find('roadAddr').text()+"</p>";
htmlStr += `<label class="col-form-label mt-4" for="detail">우편번호</label>`;
htmlStr += "<p>"+$(this).find('zipNo').text()+"</p>";
});