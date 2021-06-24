(function () {

	let MenuTpl =
		'<div id="menu_{{_namespace}}_{{_name}}" class="dialog {{#isBig}}big{{/isBig}}">' +
			'{{#isDefault}}<input type="text" name="value" placeholder="{{title}}" id="inputText"/>{{/isDefault}}' +
				'{{#isBig}}<textarea name="value"/>{{/isBig}}' +
				'<button type="button" name="submit">Accept</button>' +
				'<button type="button" name="cancel">Cancel</button>'
			'</div>' +
		'</div>'
	;

	window.DBFWCore_MENU       = {};
	DBFWCore_MENU.ResourceName = 'dbfw-menu-dialog';
	DBFWCore_MENU.opened       = {};
	DBFWCore_MENU.focus        = [];
	DBFWCore_MENU.pos          = {};

	DBFWCore_MENU.open = function (namespace, name, data) {

		if (typeof DBFWCore_MENU.opened[namespace] == 'undefined') {
			DBFWCore_MENU.opened[namespace] = {};
		}

		if (typeof DBFWCore_MENU.opened[namespace][name] != 'undefined') {
			DBFWCore_MENU.close(namespace, name);
		}

		if (typeof DBFWCore_MENU.pos[namespace] == 'undefined') {
			DBFWCore_MENU.pos[namespace] = {};
		}

		if (typeof data.type == 'undefined') {
			data.type = 'default';
		}

		if (typeof data.align == 'undefined') {
			data.align = 'top-left';
		}

		data._index = DBFWCore_MENU.focus.length;
		data._namespace = namespace;
		data._name = name;

		DBFWCore_MENU.opened[namespace][name] = data;
		DBFWCore_MENU.pos[namespace][name] = 0;

		DBFWCore_MENU.focus.push({
			namespace: namespace,
			name: name
		});

		document.onkeyup = function (key) {
			if (key.which == 27) { // Escape key
				$.post('http://' + DBFWCore_MENU.ResourceName + '/menu_cancel', JSON.stringify(data));
			} else if (key.which == 13) { // Enter key
				$.post('http://' + DBFWCore_MENU.ResourceName + '/menu_submit', JSON.stringify(data));
			}
		};

		DBFWCore_MENU.render();

	};

	DBFWCore_MENU.close = function (namespace, name) {

		delete DBFWCore_MENU.opened[namespace][name];

		for (let i = 0; i < DBFWCore_MENU.focus.length; i++) {
			if (DBFWCore_MENU.focus[i].namespace == namespace && DBFWCore_MENU.focus[i].name == name) {
				DBFWCore_MENU.focus.splice(i, 1);
				break;
			}
		}

		DBFWCore_MENU.render();

	};

	DBFWCore_MENU.render = function () {

		let menuContainer = $('#menus')[0];

		$(menuContainer).find('button[name="submit"]').unbind('click');
		$(menuContainer).find('button[name="cancel"]').unbind('click');
		$(menuContainer).find('[name="value"]').unbind('input propertychange');

		menuContainer.innerHTML = '';

		$(menuContainer).hide();

		for (let namespace in DBFWCore_MENU.opened) {
			for (let name in DBFWCore_MENU.opened[namespace]) {

				let menuData = DBFWCore_MENU.opened[namespace][name];
				let view = JSON.parse(JSON.stringify(menuData));

				switch (menuData.type) {
					case 'default': {
						view.isDefault = true;
						break;
					}

					case 'big': {
						view.isBig = true;
						break;
					}

					default: break;
				}

				let menu = $(Mustache.render(MenuTpl, view))[0];

				$(menu).css('z-index', 1000 + view._index);

				$(menu).find('button[name="submit"]').click(function () {
					DBFWCore_MENU.submit(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				$(menu).find('button[name="cancel"]').click(function () {
					DBFWCore_MENU.cancel(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				$(menu).find('[name="value"]').bind('input propertychange', function () {
					this.data.value = $(menu).find('[name="value"]').val();
					DBFWCore_MENU.change(this.namespace, this.name, this.data);
				}.bind({ namespace: namespace, name: name, data: menuData }));

				if (typeof menuData.value != 'undefined')
					$(menu).find('[name="value"]').val(menuData.value);

				menuContainer.appendChild(menu);
			}
		}

		$(menuContainer).show();
		$("#inputText").focus();
	};

	DBFWCore_MENU.submit = function (namespace, name, data) {
		$.post('http://' + DBFWCore_MENU.ResourceName + '/menu_submit', JSON.stringify(data));
	};

	DBFWCore_MENU.cancel = function (namespace, name, data) {
		$.post('http://' + DBFWCore_MENU.ResourceName + '/menu_cancel', JSON.stringify(data));
	};

	DBFWCore_MENU.change = function (namespace, name, data) {
		$.post('http://' + DBFWCore_MENU.ResourceName + '/menu_change', JSON.stringify(data));
	};

	DBFWCore_MENU.getFocused = function () {
		return DBFWCore_MENU.focus[DBFWCore_MENU.focus.length - 1];
	};

	window.onData = (data) => {

		switch (data.action) {
			case 'openMenu': {
				DBFWCore_MENU.open(data.namespace, data.name, data.data);
				break;
			}

			case 'closeMenu': {
				DBFWCore_MENU.close(data.namespace, data.name);
				break;
			}
		}

	};

	window.onload = function (e) {
		window.addEventListener('message', (event) => {
			onData(event.data);
		});
	};

})();