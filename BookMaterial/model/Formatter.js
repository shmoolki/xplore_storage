sap.ui.define([
	] , function () {
		"use strict";

		return {

			/**
			 * Rounds the number unit value to 2 digits
			 * @public
			 * @param {string} sValue the number string to be rounded
			 * @returns {string} sValue with 2 digits rounded
			 */
			editablePost: function( edit, value, header ){
				if( edit && value !== 100 && !header){
					return true;
				}else{
					return false;
				}
			},
			checkEditable: function( value ){
				if( value === "X" ){
					return false;
				}else{
					return true;
				}
			},
			
			newDevis: function( value ){
				if( !value || value === ""){
					return true;
				}else{
					return false;
				}
			},
		 	
			devisPhase:function( value ){
				if( value !== 100 ){
					return true;
				}else{
					return false;
				}
			},
			receptVisible: function( value1, value2 ){
				return value1 || value2;
			},
			labelVisible: function( value ){
				if( value === "X" ){
					return true;
				}else{
					return false;
				}
			},
			radioButtonVisible: function( value ){
				return !value;
			},
			buttonVisible: function( value, edit ){
				if( value && !edit ){
					return true;
				}else{
					return false;
				}
			},
			
			modifVisible: function( value, button ){
				if( value === true && button === true ){
					return true;
				}else{
					return false;
				}
			},
			
			numberUnit : function (sValue) {
				if (!sValue) {
					return "";
				}
				return parseFloat(sValue).toFixed(2);
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
						return "Blue";
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
			icon:function( type ){
				switch ( type ) {
					case "00":
						return "sap-icon://lateness";
					case "02":
						return "sap-icon://decline";
					case "01":
						return "sap-icon://accept";
				}
			},
			hasAttachment: function ( bool ){
				if( bool ){
					return "Green";
				}else{
					return "Grey";
				}
			},
			color:function( type ){
				switch ( type ) {
					case "00":
						return "Blue";
					case "02":
						return "Red";
					case "01":
						return "Green";
				}
			},
			showRemove:function( remove, edit ){
				if( remove && edit ){
					return true;
				}else{
					return false;
				}
			},
			enableSave:function( descr, cdate ){
				if( descr && cdate && descr !== "" && cdate !== "" ){
					return true;
				}else{
					return false;
				}
			},
			showFileButton: function( edit ){
				if( this.pageName !== "NouveauComite" && edit ){
					return true;
				}else{
					return false;
				}
			},
			editableIntervenant: function( edit, type ){
				if( edit && type === "N" ){
					return true;
				}else{
					return false;
				}
			},
			iconTimeLine: function( type ){
				switch ( type ) {
					case "001":
						return "sap-icon://it-host";
					case "002":
						return "sap-icon://cart";
					case "V":
						return "sap-icon://accept";
				}
			},
			editableHeader: function( hdr, edit ){
				if( hdr && edit ){
					return true;
				}else{
					return false;
				}
			},
			// attachementHeaderVisible: function( gr_ok, gr_ko, hdr ){
			// 	if( hdr ){
			// 		return ( gr_ok || gr_ko);
			// 	}else{
			// 		return !( gr_ok || gr_ko);
			// 	}
			// }

		};

	}
);