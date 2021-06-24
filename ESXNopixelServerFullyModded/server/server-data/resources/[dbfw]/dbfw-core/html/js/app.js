(() => {

	DBFWCore = {};
	DBFWCore.HUDElements = [];

	DBFWCore.setHUDDisplay = function (opacity) {
		$('#hud').css('opacity', opacity);
	};

	DBFWCore.insertHUDElement = function (name, index, priority, html, data) {
		DBFWCore.HUDElements.push({
			name: name,
			index: index,
			priority: priority,
			html: html,
			data: data
		});

		DBFWCore.HUDElements.sort((a, b) => {
			return a.index - b.index || b.priority - a.priority;
		});
	};

	DBFWCore.updateHUDElement = function (name, data) {

		for (let i = 0; i < DBFWCore.HUDElements.length; i++) {
			if (DBFWCore.HUDElements[i].name == name) {
				DBFWCore.HUDElements[i].data = data;
			}
		}

		DBFWCore.refreshHUD();
	};

	DBFWCore.deleteHUDElement = function (name) {
		for (let i = 0; i < DBFWCore.HUDElements.length; i++) {
			if (DBFWCore.HUDElements[i].name == name) {
				DBFWCore.HUDElements.splice(i, 1);
			}
		}

		DBFWCore.refreshHUD();
	};

	DBFWCore.refreshHUD = function () {
		$('#hud').html('');

		for (let i = 0; i < DBFWCore.HUDElements.length; i++) {
			let html = Mustache.render(DBFWCore.HUDElements[i].html, DBFWCore.HUDElements[i].data);
			$('#hud').append(html);
		}
	};

	DBFWCore.inventoryNotification = function (add, item, count) {
		let notif = '';

		if (add) {
			notif += '+';
		} else {
			notif += '-';
		}

		notif += count + ' ' + item.label;

		let elem = $('<div>' + notif + '</div>');

		$('#inventory_notifications').append(elem);

		$(elem).delay(3000).fadeOut(1000, function () {
			elem.remove();
		});
	};

	window.onData = (data) => {
		switch (data.action) {
			case 'setHUDDisplay': {
				DBFWCore.setHUDDisplay(data.opacity);
				break;
			}

			case 'insertHUDElement': {
				DBFWCore.insertHUDElement(data.name, data.index, data.priority, data.html, data.data);
				break;
			}

			case 'updateHUDElement': {
				DBFWCore.updateHUDElement(data.name, data.data);
				break;
			}

			case 'deleteHUDElement': {
				DBFWCore.deleteHUDElement(data.name);
				break;
			}

			case 'inventoryNotification': {
				DBFWCore.inventoryNotification(data.add, data.item, data.count);
			}
		}
	};

	window.onload = function (e) {
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();