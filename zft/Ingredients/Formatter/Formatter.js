jQuery.sap.declare( "CatalogMat.util.Formatter" );

CatalogMat.util.Formatter = {
	visibleDescPhoto: function( value  ){
		if( !value || value === "" ){
			return false;
		}else{
			return true;
		}	
	},
	filterLabel: function( value ){
		if( !value || value === "" ){
			return false;
		}else{
			return true;
		}
		
	},
	
	pointVirgule: function( value ){
		if( value ){
			return value.replace( ",","." );
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
	
	labelTrad: function( value ){
		var bundle	=	this.getView().getModel("i18n").getResourceBundle();
		switch ( value ) {
			case "MHDRZ":
				return bundle.getText( "CONTRAT_DATE" );
			case "I":
				return "sap-icon://add";
			case "D":
				return "sap-icon://decline";
		}
	},
	
	displayDeconditionned: function( distb, fictif, type ){
		if( fictif ){
			if( type	===	"select" ){
				return true;
			}else{
				return false;
			}
		}else{
			if( distb === "L" ){
				if( type	===	"text" ){
					return true;
				}else{
					return false;
				}	
			}else{
				if( type	===	"select" ){
					return true;
				}else{
					return false;
				}	
			}
		}
	},
	
	statAndUnit: function( unit, stat ){
		if( stat	!== "" ){
			var label	=	stat.split( "-" )[1];
			return	label + " - " + unit;
		}else{
			return unit;
		}
	},
	
	imagePlaceHolder: function( img ){
		if( img === "" || !img ){
			return	"/sap/bc/bsp/sap/zmob_ft_catmat/images/imagePlaceHolder.jpg";
		}else{
			return img;
		}
	},
	
	Tarap: function( value, fictif ){
		return value.includes( "A" );
	},
	
	nonVisibleFieldTarap: function( value, fictif ){
		return (value.includes( "A" ) && !fictif );
	},
	
	visibleFieldTarap: function( value, fictif ){
		return (value.includes( "A" ) && fictif );
	},
	
	visibleField: function( value ){
		return value.includes( "A" );
	},
	modifAutorisation:function( buttonOn, modif ){
		if ( buttonOn && modif ){
			return true;
		}else{
			return false;
		}
	},
	isFictif:function( fictif, buttonOn ){
		if( fictif && buttonOn ){
			return true;
		}else{
			return false;
		}
	},
	buttonOn:function( edit, fileEdit ){
		if( edit || fileEdit ){
			return true;
		}else{
			return false;
		}
	},
	editApproFictif:function( codeAppro, fictif, edit, autorisation, statut ){
		if( (	codeAppro === "" || !codeAppro) && fictif && edit 
				&& ( autorisation.includes( "M" ) || ( this.pageName === "NewArticle" && autorisation.includes( "C" ) ) ) 
				&& Number( statut ) < 40 ){
			return true;
		}else{
			return false;
		}
	},
	editApproFictif2:function( codeAppro, fictif, edit, statut ){
		if( ( codeAppro === "" || !codeAppro) && fictif && edit && Number( statut ) < 40  ){
			return true;
		}else{
			return false;
		}
	},
	editFictif:function( fictif, edit, autorisation ){
		// fictif && edit &&
		if( 	fictif && edit && autorisation.includes( "M" ) ){
			return true;
		}else{
			return false;
		}
	},
	editFictifAppro:function( fictif, edit, autorisation, stat ){
		// fictif && edit &&
		if( 	fictif && edit && autorisation.includes( "M" ) && Number( stat ) >= 30 ){
			return true;
		}else{
			return false;
		}
	},
	editRecipeFictif:function( fictif, edit, autorisation, statut ){
		// fictif && edit &&
		if( 	fictif && edit && autorisation.includes( "M" ) && Number( statut ) < 40){
			return true;
		}else{
			return false;
		}
	},
	deleteFictif:function( fictif, edit ){
		if( fictif && edit ){
			return "Delete";
		}else{
			return "None";
		}
	},
	
	isDeconditionned:function( value, code, distb ){
		if( code ){
			if( code.startsWith( "AF" ) || distb !== "L" || value === 'N' ){
				return value;			
			}else{
				return "-";
			}
		}
	},
	
	// isGroup:function( group , fictif ){
	// 	if( group ){
	// 		return false;
	// 	}else{
	// 		return true;
	// 	}
	// },
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
	haveFile:function( cofil ){
		if( cofil ){
			return "Green";
		}else{
			return "Grey";
		}	
			
	},
	haveText:function( text ){
		if( text === "" || !text ){
			return "Reject";
		}else{
			return "Accept";
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
			case "TXT":
				return "Black";
			case "":
				return "Grey";
		}
	},
	visibleTypologie:function( fictif ){
		return !fictif;
	},
	
	enabledNewArticle:function( DESCP, ACNUM, MAKTX, MEINS, TARAP ){
		if( DESCP !== "" && ACNUM !== "" &&
			MAKTX !== "" && MEINS !== "" 
			&& TARAP !== "" ){
				return true;
			}else{
				return false;
			}
	}
};