jQuery.sap.declare( "CatalogRecette.util.Formatter" );

CatalogRecette.util.Formatter = {
	
	filterLabel: function( value ){
		if( !value || value === "" ){
			return false;
		}else{
			return true;
		}
		
	},	
	modifAutorisation:function( buttonOn, modif, stats ){
		if ( buttonOn && modif && stats !== "25"){
			return true;
		}else{
			return false;
		}
	},
	
	editableCheckBox: function( edit, ensgn ){
		if( !ensgn ){
			return false;
		}else{
			return edit;
		}
	},
	
	editableFamily: function( edit, frnum ){
		if( !edit ){
			return false;
		}else{
			if( frnum === "" ){
				return true;
			}else{
				return false;
			}
		}
	},
	
	warningVisible: function( stats ,warn){
		if( stats === "50" || stats === "1" || ( warn && warn !== "" ) ){
			return true;
		}else{
			return false;
		}
	},
	
	bigWarningVisible: function( model ){
		if( model[0] ){
			return true;
		}else{
			return false;
		}
	},
	
	addTimeToDate: function( date, time ) {
        var ms		= time.ms,
        	seconds = parseInt( ( ms / 1000 ) % 60 ), 
        	minutes = parseInt( ( ms / ( 1000 * 60 ) ) % 60 ), 
        	hours	= parseInt( ( ms / ( 1000 * 60 * 60 ) ) % 24 );

        hours = (hours < 10) ? "0" + hours : hours;
        minutes = (minutes < 10) ? "0" + minutes : minutes;
        seconds = (seconds < 10) ? "0" + seconds : seconds;
		
		date.setHours( hours );
		date.setMinutes( minutes );
		date.setSeconds( seconds );
        return date;
    },
	
	iconChange: function( value ){
		switch ( value ) {
			case "U":
				return "sap-icon://edit";
			case "I":
				return "sap-icon://add";
			case "D":
				return "sap-icon://decline";
		}
	},
	
	textChange: function( field, newvl, oldvl ){
		if( field	===	"" ){
			return "";
		}else{
			return "de " + newvl + " à " + oldvl;
		}
	},
	
	modifAutorisationIngredient:function( buttonOn, modif, isfic, stats ){
		if( isfic ){
			if ( buttonOn && modif ){
				return true;
			}else{
				return false;
			}
		}else{
			if ( buttonOn && modif && ( Number( stats ) <= 12 || Number( stats ) === 22 ) ){
				return true;
			}else{
				return false;
			}
		}
	},
	imagePlaceHolder: function( img ){
		if( img === "" || !img ){
			return	"/sap/bc/bsp/sap/zmob_ft_catrec/images/imagePlaceHolder.jpg";
		}else{
			return img;
		}
	},
	TimeFormat: function( value ) {
		if( !value ) return;
		
		var timeFormat = sap.ui.core.format.DateFormat.getTimeInstance({pattern: "HH:mm:ss"}); 
		var TZOffsetMs = new Date(0).getTimezoneOffset()*60*1000;
		return timeFormat.format( new Date( value.ms + TZOffsetMs ));
	},
	DateFormat:function( value ){
		if ( !value || value.ms === 0) {  
  			return "00:00:00";  
  		}
  		else{
  			var time	=	new Date( value.ms ),
  				hour	=	time.getUTCHours(),
  				min		=	time.getMinutes(),
  				sec		=	time.getSeconds();
  				
  			if( hour.toString().length < 2){
  				hour = "0" + hour;
  			}
  			if( min.toString().length < 2){
  				min = "0" + min;
  			}
  			if( sec.toString().length < 2){
  				sec = "0" + sec;
  			}
  				
  			return hour + ":" + min + ":" + sec;
	  		
	  	}  
	},
	State:function( cnfic, isfic ){
			if( cnfic ){
				return "Error";
			}else{
				return "Success";
			}
		
	},
	NewRecipe:function( newR, edit ){
		if( newR && edit ){
			return true;
		}else{
			return false;
		}
	},
	version:function( version ){
		if( version === "true" ){
			return true;
		}else{
			return false;
		}
	},
	anteVersion:function( version ){
		if( version === "true" ){
			return false;
		}else{
			return true;
		}
	},
	
	 isFictif:function( fictif ){
		if( fictif ){
			return "sap-icon://accounting-document-verification";
		}else{
			return "sap-icon://inspection";
		}
	},
	FTEdit:function( Rname, Edit ){
		if( Rname ){
			if( Rname.includes("SR") && Edit){
				return true;
			}else{
				return false;
			}
		}
	},
	Simulation:function( Rname){
		if( Rname ){
			if( Rname.includes("SR") ){
				return true;
			}else{
				return false;
			}
		}
	},
	isSimulation:function( Rname){
		if( Rname ){
			if( Rname.includes("SR") ){
				return false;
			}else{
				return true;
			}
		}
	},
	FT:function( isfic){
		return !isfic;
	},
	editableDate:function( edit, value ){
		if( thisDetail.pageName	===	"DuplicationRecette" && edit ){
			return true;
		}
		var date		=	new Date(),
			mounth		=	date.getMonth() + 1 + "",
			day			=	date.getUTCDate() + "";
		if( mounth.length < 2 ){
			mounth = "0" + mounth;
		}
		if( day.length < 2 ){
			day = "0" + day;
		}
		var temp;
		if( value && value.includes("-") ){
			temp	=	value.split("-");
			temp	=	temp[0] + temp[1] + temp[2];
		}else{
			temp	=	value;
		}
			date	=	date.getFullYear() + mounth + day;
			date	=	Number(date);
			value	=	Number( temp );
		if( edit && value >= date ){
			return true;
		}else{
			return false;
		}
	},
	initStat: function( stats ){
		if( stats === "00" ){
			return true;
		}else{
			return false;
		}
	},
	
	editableEndDate:function( edit, value, end, fictif ){
		if( thisDetail.pageName	===	"DuplicationRecette" && edit  ){
			return true;
		}
		if( edit && fictif ){
			return true;
		}else{
			var date		=	new Date(),
				mounth		=	date.getMonth() + 1 + "",
				day			=	date.getUTCDate() + "";
			if( mounth.length < 2 ){
				mounth = "0" + mounth;
			}
			if( day.length < 2 ){
				day = "0" + day;
			}
			date	=	date.getFullYear() + mounth + day;
			date	=	Number( date );
			value	=	Number( value );
			end		=	Number( end );
			if( edit && value >= date ){
				return true;
			}else{
				return false;
			}
		}
	},
	iconType:function( type ){
		switch ( type ) {
			case "IMG":
				return "sap-icon://picture";
			case "DOC":
				return "sap-icon://doc-attachment";
			case "PDF":
				return "sap-icon://pdf-attachment";
			case "XLS":
				return "sap-icon://excel-attachment";
			case "CVS":
				return "sap-icon://excel-attachment";
			case "TXT":
				return "sap-icon://attachment-text-file";
			case "":
				return "sap-icon://attachment";
		}
	},
	iconTypeColor:function( type ){
		switch ( type ) {
			case "IMG":
				return "Orange";
			case "DOC":
				return "Bleu";
			case "PDF":
				return "Red";
			case "XLS":
				return "Green";
			case "CVS":
				return "Green";
			case "TXT":
				return "Black";
			case "":
				return "Grey";
		}
	},
	iconChange: function( value ){
		switch ( value ) {
			case "U":
				return "sap-icon://edit";
			case "I":
				return "sap-icon://add";
			case "D":
				return "sap-icon://decline";
		}
	},
	
	enabledAddVersion: function( descr ){
		if( !descr || descr === ""){
			return false;
		}else{
			return true;
		}
	},
	enabledPrint: function( VKORG, VTWEG, PLTYP, BDATE ){
		if( !VKORG || !VTWEG || !PLTYP || !BDATE || VKORG === "" || VTWEG === "" || PLTYP === "" || BDATE === "" ){
			return false;
		}else{
			return true;
		}
	},
	formatDate: function( date , join ) {
    var d = new Date(date),
        month = '' + (d.getMonth() + 1),
        day = '' + d.getDate(),
        year = d.getFullYear();

    if (month.length < 2) month = '0' + month;
    if (day.length < 2) day = '0' + day;

    return [year, month, day].join(join);
	}
}