var express = require('express');
var router = express.Router();
const puppeteer = require('puppeteer');

/* GET home page. */
router.get('/', function(req, res, next) {
	puppeteer.launch({
		headless: true,
		args: ['--no-sandbox']
	}).then(function(browser){
	  browser.newPage().then(function(page){
	    page.goto('https://feeds.chain.link/', {waitUntil: 'networkidle2'}).then(function(){
		  
		  page.content().then(function(pageData){
		  		 page.$$('.listing-grid__item').then(function(items){
	  				let priceList = items.map(function(item){
	  					return item.$eval('.listing-grid__item--name', elem => elem.innerText).then(function(symbol){
						let symbolParsed = symbol.split("/");
						let quote = symbolParsed[0].trim();
						let base = symbolParsed[1].trim();
		
						if (base === 'USD') {
							return item.$eval('.listing-grid__item--answer', elem => elem.innerText).then(function(price){
								let priceParsed = price.split("$")[1].trim();
								return {symbol: quote, price: priceParsed};
							});
						} else {
							return null;
						}  						
				  	});
		  		});
		  		
		  		Promise.all(priceList).then(function(priceList){
		  			  res.send({'data': priceList.filter(Boolean)});
		  		});
		    });
		})
	  })    
	
	});
	
	});
});

module.exports = router;
