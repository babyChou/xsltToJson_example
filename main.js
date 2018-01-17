var xmlUrl = 'tunerlist.xml';
var xslUrl = 'tunerList.xsl';

$(function(){



	$.get(xmlUrl)
	.done(function(data) {
		var xml = data;

		$.get(xslUrl).done(function(xsl){
			
			try {
				var xsltProcessor = new XSLTProcessor();
				var myDocument = document.implementation.createDocument("","", null);
				
				xsltProcessor.importStylesheet(xsl);
				
				strJson = xsltProcessor.transformToFragment(xml, myDocument);
			
				$('#myCode').html(strJson);
			}
			catch (err) {
				console.log(err.message);
			}

		});
		
	}).fail(function() {
		alert( "error" );
	});


});