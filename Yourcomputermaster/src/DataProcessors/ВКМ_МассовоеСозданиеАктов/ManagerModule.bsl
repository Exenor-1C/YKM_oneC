#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
#Область СлужебныеПроцедурыИФункции
Функция ВыполнитьЗаполнениеТЧФоново(ДатаНачала, ДатаОкончания) Экспорт	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ДоговорыКонтрагентов.Ссылка КАК Договор,
	               |	ЕСТЬNULL(ОбработкаЗаказовОбороты.Регистратор, ЗНАЧЕНИЕ(Документ.РеализацияТоваровУслуг.ПустаяСсылка)) КАК Реализация
	               |ИЗ
	               |	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ОбработкаЗаказов.Обороты(&ДатаНачала, &ДатаОкончания, Регистратор, ) КАК ОбработкаЗаказовОбороты
	               |		ПО ДоговорыКонтрагентов.Владелец = ОбработкаЗаказовОбороты.Контрагент
	               |			И (ОбработкаЗаказовОбороты.Регистратор ССЫЛКА Документ.РеализацияТоваровУслуг)
	               |			И (ОбработкаЗаказовОбороты.Период МЕЖДУ &ДатаНачала И &Датаокончания)
	               |ГДЕ
	               |	ДоговорыКонтрагентов.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.АбонентскаяПлата)
	               |	И ДоговорыКонтрагентов.ДействуетДо >= &ДатаНачала";
	Запрос.УстановитьПараметр("АбонентскаяПлата", Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить());
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ДатаОкончания);
	Выборка = Запрос.Выполнить().Выбрать();
	
	ОбъектТЧ = Новый ТаблицаЗначений();
	ОбъектТЧ.Колонки.Добавить("Договор");
	ОбъектТЧ.Колонки.Добавить("Реализация");
	Количество = Выборка.Количество();
	Счетчик = 0;
		Пока Выборка.Следующий() Цикл
		
			Строка = ОбъектТЧ.Добавить();
			Строка.Договор = Выборка.Договор;
			Строка.Реализация = Выборка.Реализация;
			Счетчик = Счетчик + 1;
			ДлительныеОперации.СообщитьПрогресс(Счетчик / Количество * 100);
		КонецЦикла;
		
	Возврат ОбъектТЧ;
	
КонецФункции

Функция ВыполнитьЗаполнениеРеализацийФоново (ДатаНачала, ДатаОкончания) Экспорт
	
	АбонентскаяПлата = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ДоговорыКонтрагентов.Ссылка КАК Договор,
	               |	ДоговорыКонтрагентов.Владелец КАК Контрагент,
	               |	ДоговорыКонтрагентов.Организация КАК Организация,
	               |	ДоговорыКонтрагентов.СуммаЕжемесячнойАбонентскойПлаты КАК СуммаЕжемесячнойАбонентскойПлаты,
	               |	ДоговорыКонтрагентов.ДействуетДо КАК ДействуетДо,
	               |	ОбработкаЗаказовОбороты.Заказ КАК Заказ,
	               |	ЕСТЬNULL(ОбработкаЗаказовОбороты.Регистратор, ЗНАЧЕНИЕ(Документ.РеализацияТоваровУслуг.ПустаяСсылка)) КАК Реализация
	               |ИЗ
	               |	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ОбработкаЗаказов.Обороты(&ДатаНачала, &ДатаОкончания, Регистратор, ) КАК ОбработкаЗаказовОбороты
	               |		ПО ДоговорыКонтрагентов.Владелец = ОбработкаЗаказовОбороты.Контрагент
	               |			И (ОбработкаЗаказовОбороты.Регистратор ССЫЛКА Документ.РеализацияТоваровУслуг)
	               |			И ДоговорыКонтрагентов.Ссылка = ОбработкаЗаказовОбороты.Заказ
	               |			И (ОбработкаЗаказовОбороты.Период МЕЖДУ &ДатаНачала И &Датаокончания)
	               |ГДЕ
	               |	ДоговорыКонтрагентов.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.АбонентскаяПлата)
	               |	И ДоговорыКонтрагентов.ДействуетДо >= &ДатаНачала";
	Запрос.УстановитьПараметр("АбонентскаяПлата", АбонентскаяПлата);
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ДатаОкончания);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	ОбъектТЧ = Новый ТаблицаЗначений();
	ОбъектТЧ.Колонки.Добавить("Договор");
	ОбъектТЧ.Колонки.Добавить("Реализация");
	Количество = Выборка.Количество();
	Счетчик = 0;
	Пока Выборка.Следующий() Цикл
		
		Если ЗначениеЗаполнено(Выборка.Реализация) Тогда
			Строка = ОбъектТЧ.Добавить();
			Строка.Договор = Выборка.Договор;
			Строка.Реализация = Выборка.Реализация;
			Продолжить;
		КонецЕсли;
		
		Документ = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
		Документ.Контрагент = Выборка.Контрагент;
		Документ.Организация = Выборка.Организация;
		Документ.Договор = Выборка.Договор;
		Документ.Ответственный = ПараметрыСеанса.ТекущийПользователь;
		Документ.Основание = Выборка.Договор;
		Документ.Дата = ДатаНачала;
		Документ.ВыполнитьАвтозаполнение();
		
		
		//Услуги = Документ.Услуги.Добавить();
		//Услуги.Номенклатура = АбонентскаяПлата;
		//Если Выборка.ДействуетДо < ДатаОкончания Тогда
		//	Услуги.Сумма = Выборка.СуммаЕжемесячнойАбонентскойПлаты / День(ДатаОкончания) * День(Выборка.ДействуетДо);
		//Иначе
		//	Услуги.Сумма = Выборка.СуммаЕжемесячнойАбонентскойПлаты;
		//КонецЕсли;
		Документ.ПроверитьЗаполнение();
		Документ.Записать(РежимЗаписиДокумента.Проведение);
		
		Строка = ОбъектТЧ.Добавить();
		Строка.Договор = Выборка.Договор;
		Строка.Реализация = Документ.Ссылка;
		Счетчик = Счетчик + 1;
		ДлительныеОперации.СообщитьПрогресс(Счетчик / Количество * 100);
	КонецЦикла;
	
	Возврат ОбъектТЧ;
	
КонецФункции
#КонецОбласти
#КонецЕсли