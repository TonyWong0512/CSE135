<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<jsp:include page="common/auth.jsp" />
<jsp:include page="common/header.jsp" />
<body>

  <div class="container">
    <div class="alert alert-error">
      <button type="button" class="close" onclick="javascript:window.location.href='categories.jsp'">&times;</button>
      <strong>Error!</strong> hahahah!
    </div>
  </div>

	<a type="button" value="test" href="">test</a>
	<script src="js/jquery-1.9.1.js"></script>
	<script src="js/bootstrap.min.js"></script>
	<script type="text/javascript"
		src="./js/fancybox/jquery.fancybox-1.3.4_patch.js"></script>
	<link rel="stylesheet" href="./js/fancybox/jquery.fancybox-1.3.4.css"
		type="text/css" media="screen" />
	<script>
		$(document).ready(function(){
			$("a").fancybox({
	            'width'             : 900,
	            'height'            : 520,
	            'autoScale'         : false,
	            'transitionIn'      : 'elastic',
	            'transitionOut'     : 'elastic',
	            'type'              : 'iframe',
	            'href'              : "cart.jsp"
	        });
			

		});
	</script>
</body>
</html>

