#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Функция ЗапросВыполненныхРабот (Контрагент, Дата) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	СУММА(ВКМ_ВыполненныеКлиентуРаботыОбороты.КоличествоЧасовОборот) КАК КоличествоЧасовОборот,
	|	СУММА(ВКМ_ВыполненныеКлиентуРаботыОбороты.СуммаКОплатеОборот) КАК СуммаКОплатеОборот,
	|	ВКМ_ВыполненныеКлиентуРаботыОбороты.Клиент
	|ИЗ
	|	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы.Обороты(НАЧАЛОПЕРИОДА(&Дата, МЕСЯЦ), КОНЕЦПЕРИОДА(&Дата, МЕСЯЦ),,
	|		Клиент = &Контрагент) КАК ВКМ_ВыполненныеКлиентуРаботыОбороты
	|СГРУППИРОВАТЬ ПО
	|	ВКМ_ВыполненныеКлиентуРаботыОбороты.Клиент";
	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("Контрагент", Контрагент);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Возврат Выборка;
	
КОнецФункции
#КонецОбласти

#КонецЕсли