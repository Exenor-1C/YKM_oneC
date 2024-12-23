#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий
Процедура ОбработкаПроведения(Отказ, Режим)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	СформироватьДвижения();
	
	РассчитатьНачисления();
	
	РассчитатьНачисленияОтпусков();
	
	РассчитатьУдержания();
	
	ПроведениеВзаиморасчетов();
	
КонецПроцедуры
#КонецОбласти

#Область СлужебныеПроцедурыИФункции
Процедура СформироватьДвижения();
	
	Для Каждого Строка Из Сотрудники Цикл
		Движение = Движения.ВКМ_ОсновоныеНачисления.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.ВидРасчета = Строка.ТипНачисления;
		Движение.ПериодДействияНачало = Строка.ДатаНачала;
		Движение.ПериодДействияКонец = КонецДня(Строка.ДатаОкончания);
		НачалоБаза = НачалоМесяца(Строка.ДатаНачала);
		КонецБаза = НачалоМесяца(Строка.ДатаОкончания);
		Движение.БазовыйПериодНачало = НачалоБаза;
		Движение.БазовыйПериодКонец = КонецБаза;
		ДВижение.Сотрудник = Строка.Сотрудник;
		Движение.Подразделение = Строка.Подразделение;
		Если Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Оклад Тогда
			Если Движение.Подразделение = Справочники.ВКМ_ПодразделенияСотрудников.Специалист Тогда
				Движение.Ставка = РегистрыСведений.ВКМ_УсловияОплатыСотрудников.ОкладСотрудника(Строка.Сотрудник, Движение.Подразделение, Строка.ДатаНачала) + 
					РегистрыНакопления.ВКМ_ВыполненныеСотрудникомРаботы.ВыполненныеСотрудникомРаботы(Строка.Сотрудник, СТрока.ДатаНачала, СТрока.ДатаОкончания);
			Иначе
				Движение.Ставка = РегистрыСведений.ВКМ_УсловияОплатыСотрудников.ОкладСотрудника(Строка.Сотрудник, Движение.Подразделение, Строка.ДатаНачала);
			КонецЕсли;
		КонецЕсли;
		
		Движение.ГрафикРабот = Строка.ГрафикРабот;
		
		Если Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск Тогда
			
			НачалоБаза = НачалоМесяца(ДобавитьМесяц(Строка.ДатаНачала, -12));
			КонецБаза = НачалоМесяца(Строка.ДатаНачала) - 1;
			Движение.БазовыйПериодНачало = НачалоБаза;
			Движение.БазовыйПериодКонец = КонецБаза;
			
		КонецЕсли;
		
	КонецЦикла;
	Движения.ВКМ_ОсновоныеНачисления.Записать();
КонецПроцедуры

Процедура РассчитатьНачисления()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ОсновоныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки,
	               |	ВКМ_ОсновоныеНачисленияДанныеГрафика.ЗначениеФактическийПериодДействия КАК ЗначениеФактическийПериодДействия,
	               |	ВКМ_ОсновоныеНачисленияДанныеГрафика.ЗначениеПериодДействия КАК ЗначениеПериодДействия,
	               |	ВКМ_ОсновоныеНачисленияДанныеГрафика.Ставка КАК Ставка,
	               |	ВКМ_ОсновоныеНачисленияДанныеГрафика.Подразделение КАК Подразделение
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ОсновоныеНачисления.ДанныеГрафика(
	               |			Регистратор = &Регистратор
	               |				И ВидРасчета = &Оклад) КАК ВКМ_ОсновоныеНачисленияДанныеГрафика";
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	Запрос.УстановитьПараметр("Оклад", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Оклад);
	Результат = Запрос.Выполнить().Выбрать();
	
	Пока Результат.Следующий() Цикл
		Движение = Движения.ВКМ_ОсновоныеНачисления[Результат.НомерСтроки - 1];
		Движение.Сумма = Результат.Ставка / Результат.ЗначениеПериодДействия * Результат.ЗначениеФактическийПериодДействия;
	КонецЦикла;
	
	Движения.ВКМ_ОсновоныеНачисления.Записать(, Истина);
	
КонецПроцедуры

Процедура ПроведениеВзаиморасчетов()
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записывать = Истина;
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ОсновоныеНачисления.Сумма КАК СуммаНачисления,
	               |	ВКМ_ОсновоныеНачисления.Сотрудник КАК Сотрудник,
	               |	ВКМ_ОсновоныеНачисления.Подразделение КАК Подразделение,
	               |	ВКМ_Удержания.Сумма КАК СуммаУдержания
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ОсновоныеНачисления КАК ВКМ_ОсновоныеНачисления
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
	               |		ПО ВКМ_ОсновоныеНачисления.Сотрудник = ВКМ_Удержания.Сотрудник
	               |			И ВКМ_ОсновоныеНачисления.Подразделение = ВКМ_Удержания.Подразделение
	               |			И ВКМ_ОсновоныеНачисления.Регистратор = ВКМ_Удержания.Регистратор
	               |ГДЕ
	               |	ВКМ_ОсновоныеНачисления.Регистратор = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Результат = Запрос.Выполнить().Выбрать();
	
	Пока Результат.Следующий() Цикл
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.ДобавитьПриход();
		Движение.Сотрудник = Результат.Сотрудник;
		ДВижение.Подразделение = Результат.Подразделение;
		Движение.Сумма = Результат.СуммаНачисления - Результат.СуммаУдержания;
		Движение.Период = Дата;
	КонецЦикла;
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();
	
КонецПроцедуры

Процедура РассчитатьНачисленияОтпусков()
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.ПериодДействияНачало КАК ПериодДействияНачало,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.ПериодДействияКонец КАК ПериодДействияКонец,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.БазовыйПериодНачало КАК БазовыйПериодНачало,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.БазовыйПериодКонец КАК БазовыйПериодКонец,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.Сотрудник КАК Сотрудник,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.Подразделение КАК Подразделение,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.Ставка КАК Ставка,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.ГрафикРабот КАК ГрафикРабот,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.СуммаБаза КАК СуммаБаза,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.НомерСтроки КАК НомерСтроки
	               |ПОМЕСТИТЬ ВТ_База
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ОсновоныеНачисления.БазаВКМ_ОсновоныеНачисления(
	               |			&Измерения,
	               |			&Измерения,
	               |			,
	               |			Регистратор = &Ссылка
	               |				И ВидРасчета = &Отпуск) КАК ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_База.ПериодДействияНачало КАК ПериодДействияНачало,
	               |	ВТ_База.ПериодДействияКонец КАК ПериодДействияКонец,
	               |	ВТ_База.БазовыйПериодНачало КАК БазовыйПериодНачало,
	               |	ВТ_База.БазовыйПериодКонец КАК БазовыйПериодКонец,
	               |	ВТ_База.Сотрудник КАК Сотрудник,
	               |	ВТ_База.Подразделение КАК Подразделение,
	               |	ВТ_База.Ставка КАК Ставка,
	               |	ВТ_База.ГрафикРабот КАК ГрафикРабот,
	               |	ВТ_База.СуммаБаза КАК Сумма,
	               |	СУММА(ВКМ_ГрафикРабот.Значение) КАК РабочихДней,
	               |	РАЗНОСТЬДАТ(ВТ_База.ПериодДействияНачало, ВТ_База.ПериодДействияКонец, ДЕНЬ) + 1 КАК ДнейОтпуска,
	               |	ВТ_База.НомерСтроки КАК НомерСтроки
	               |ИЗ
	               |	ВТ_База КАК ВТ_База
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВКМ_ГрафикРабот КАК ВКМ_ГрафикРабот
	               |		ПО ВТ_База.ГрафикРабот = ВКМ_ГрафикРабот.ГрафикРабот
	               |			И (ВКМ_ГрафикРабот.Дата МЕЖДУ ВТ_База.БазовыйПериодНачало И ВТ_База.БазовыйПериодКонец)
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВТ_База.ПериодДействияНачало,
	               |	ВТ_База.ПериодДействияКонец,
	               |	ВТ_База.БазовыйПериодНачало,
	               |	ВТ_База.БазовыйПериодКонец,
	               |	ВТ_База.Сотрудник,
	               |	ВТ_База.Подразделение,
	               |	ВТ_База.Ставка,
	               |	ВТ_База.ГрафикРабот,
	               |	ВТ_База.СуммаБаза,
	               |	ВТ_База.НомерСтроки";
	
	Измерения = Новый Массив;
	Измерения.Добавить("Сотрудник");
	Измерения.Добавить("Подразделение");
	
	Запрос.УстановитьПараметр("Измерения", Измерения);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Отпуск", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск);
	Результат = Запрос.Выполнить().Выбрать();
	
	Если Результат.Количество() > 0 Тогда
		Пока Результат.Следующий() Цикл
			Движение = Движения.ВКМ_ОсновоныеНачисления[Результат.НомерСтроки - 1];
			Движение.Сумма = Результат.Сумма;
		КонецЦикла;;
	КонецЕсли;
	
	Движения.ВКМ_ОсновоныеНачисления.Записать(, Истина);
	
КонецПроцедуры

Процедура РассчитатьУдержания()
	
	Движения.ВКМ_Удержания.Записывать = Истина;
	ДВижения.ВКМ_Удержания.Записать();
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.НомерСтроки КАК НомерСтроки,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.Сотрудник КАК Сотрудник,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.Подразделение КАК Подразделение,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.СуммаБаза КАК СуммаБаза,
	               |	ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления.ВидРасчета КАК ВидРасчета
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ОсновоныеНачисления.БазаВКМ_ОсновоныеНачисления(&Измерения, &Измерения, &Разрезы, Регистратор = &Регистратор) КАК ВКМ_ОсновоныеНачисленияБазаВКМ_ОсновоныеНачисления";
	Измерения = Новый Массив;
	Измерения.Добавить("Подразделение");
	Измерения.Добавить("Сотрудник");
	
	Запрос.УстановитьПараметр("Измерения", Измерения);
	
	Разрезы = Новый Массив;
	Разрезы.Добавить("Регистратор");
	
	Запрос.УстановитьПараметр("Разрезы", Разрезы);
	
	Запрос.УстановитьПараметр("Регистратор", Ссылка);
	
	Результат = Запрос.Выполнить().Выбрать();
	
	Пока Результат.Следующий() Цикл
		Движение = Движения.ВКМ_Удержания.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.Сотрудник = Результат.Сотрудник;
		Движение.Подразделение = Результат.Подразделение;
		Движение.Начисление = Результат.ВидРасчета;
		Движение.Сумма = Результат.СуммаБаза / 100 * 13;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
	КонецЦикла;
	
	Движения.ВКМ_Удержания.Записать();
	
КонецПроцедуры;

#КонецОбласти

#КонецЕсли
