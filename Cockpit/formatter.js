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
			numberUnit : function (sValue) {
				if (!sValue) {
					return "";
				}
				return parseFloat(sValue).toFixed(2);
			},
			filterLabel: function( value ){
				if( !value || value === "" ){
					return false;
				}else{
					return true;
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
			colorChange: function( value ){
				switch ( value ) {
					case "U":
						return "Orange";
					case "I":
						return "Green";
					case "D":
						return "Red";
				}	
			},
			appName: function( value ){
				var bundle	=	this.getView().getModel("i18n").getResourceBundle();
				if( value.includes( "FT" ) || value.includes( "SR" ) ){
					return bundle.getText( "RECETTE" );
				}else if( value.includes( "CR" ) ){
					return bundle.getText( "CARTE" );
				}else{
					return bundle.getText( "INGREDIENT" );
				}
			},
			
			formatTime: function( value ){
				var date	=	new Date( value.ms ),
					hour	=	date.getUTCHours() + "",
					minute	=	date.getUTCMinutes() + "";
				if( hour.length < 2 ){
					hour = "0" + hour;
				}
				if( minute.length < 2 ){
					minute = "0" + minute;
				}
				return hour + ":" + minute;
			}

		};

	}
);