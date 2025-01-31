
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

Функция ДобавитьКомандуСоздатьНаОсновании(КомандыСозданияНаОсновании) Экспорт
	
	Если ПравоДоступа("Добавление", Метаданные.Документы.РеализацияТоваровУслуг) Тогда
		
        КомандаСоздатьНаОсновании = КомандыСозданияНаОсновании.Добавить();
        КомандаСоздатьНаОсновании.Менеджер = Метаданные.Документы.РеализацияТоваровУслуг.ПолноеИмя();
        КомандаСоздатьНаОсновании.Представление = ОбщегоНазначения.ПредставлениеОбъекта(Метаданные.Документы.РеализацияТоваровУслуг);
        КомандаСоздатьНаОсновании.РежимЗаписи = "Проводить";
		
		Возврат КомандаСоздатьНаОсновании;
		
	КонецЕсли;

	Возврат Неопределено;
	
КонецФункции

Процедура ДобавитьКомандыСозданияНаОсновании(КомандыСозданияНаОсновании, Параметры) Экспорт
	
    Документы.РеализацияТоваровУслуг.ДобавитьКомандуСоздатьНаОсновании(КомандыСозданияНаОсновании);
    Документы.ОплатаОтПокупателя.ДобавитьКомандуСоздатьНаОсновании(КомандыСозданияНаОсновании);
	
КонецПроцедуры

Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
	
	// Оказанные услуги
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "ОказанныеУслуги";
	КомандаПечати.Представление = НСтр("ru = 'Выполненные услуги'");
	КомандаПечати.Порядок = 5;
		
КонецПроцедуры

Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	ПечатнаяФорма = УправлениеПечатью.СведенияОПечатнойФорме(КоллекцияПечатныхФорм, "ОказанныеУслуги");
	Если ПечатнаяФорма <> Неопределено Тогда
	    ПечатнаяФорма.ТабличныйДокумент = ПечатьОказанныхУслуг(МассивОбъектов, ОбъектыПечати);
	    ПечатнаяФорма.СинонимМакета = НСтр("ru = 'Оказанные услуги'");
	    ПечатнаяФорма.ПолныйПутьКМакету = "Документ.РеализацияТоваровУстуг.ПФ_MXL_ВКМ_МакетВыполненныхУслуг";
	КонецЕсли;
		
КонецПроцедуры


#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ПечатьОказанныхУслуг(МассивОбъектов, ОбъектыПечати)
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.КлючПараметровПечати = "ПараметрыПечати_ОказанныеУслуги";
	
	Макет = УправлениеПечатью.МакетПечатнойФормы("Документ.РеализацияТоваровУслуг.ПФ_MXL_ВКМ_МакетВыполненныхУслуг");
	
	ДанныеДокументов = ПолучитьДанныеДокументов(МассивОбъектов);
	
	ПервыйДокумент = Истина;
	
	Пока ДанныеДокументов.Следующий() Цикл
		
		Если Не ПервыйДокумент Тогда
			// Все документы нужно выводить на разных страницах.
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
		КонецЕсли;
		
		ПервыйДокумент = Ложь;
		
		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		
		ВывестиЗаголовокЗаказа(ДанныеДокументов, ТабличныйДокумент, Макет);
		
		ВывестиТоварыУслуги(ДанныеДокументов, ТабличныйДокумент, Макет);
					
		ВывестиРеквизитыСторон(ДанныеДокументов, ТабличныйДокумент, Макет);
		
        // В табличном документе необходимо задать имя области, в которую был 
        // выведен объект. Нужно для возможности печати комплектов документов.
        УправлениеПечатью.ЗадатьОбластьПечатиДокумента(ТабличныйДокумент, 
            НомерСтрокиНачало, ОбъектыПечати, ДанныеДокументов.Ссылка);		
		
	КонецЦикла;	
		
	Возврат ТабличныйДокумент;
	
КонецФункции

Функция ПолучитьДанныеДокументов(МассивОбъектов)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	РеализацияТоваровУслуг.Дата КАК Дата,
	               |	РеализацияТоваровУслуг.Номер КАК Номер,
	               |	РеализацияТоваровУслуг.Организация КАК Организация,
	               |	РеализацияТоваровУслуг.Контрагент КАК Контрагент,
	               |	РеализацияТоваровУслуг.Договор КАК Договор,
	               |	РеализацияТоваровУслуг.СуммаДокумента КАК СуммаДокумента,
	               |	РеализацияТоваровУслуг.Ответственный КАК Ответственный,
	               |	РеализацияТоваровУслуг.Ссылка КАК Ссылка,
	               |	РеализацияТоваровУслуг.Товары.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Товары,
	               |	РеализацияТоваровУслуг.Услуги.(
	               |		Ссылка КАК Ссылка,
	               |		НомерСтроки КАК НомерСтроки,
	               |		Номенклатура КАК Номенклатура,
	               |		Количество КАК Количество,
	               |		Цена КАК Цена,
	               |		Сумма КАК Сумма
	               |	) КАК Услуги
	               |ИЗ
	               |	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	               |ГДЕ
	               |	РеализацияТоваровУслуг.Ссылка В(&МассивОбъектов)";
	
	Запрос.УстановитьПараметр("МассивОбъектов", МассивОбъектов);
	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции

Процедура ВывестиЗаголовокЗаказа(ДанныеДокументов, ТабличныйДокумент, Макет)
	
	ОбластьЗаголовокДокумента = Макет.ПолучитьОбласть("ОбластьШапка");
	//
	//ДанныеПечати = Новый Структура;
	//
	//ШаблонЗаголовка = "Заказ покупателя %1 от %2";
	//ТекстЗаголовка = СтрШаблон(ШаблонЗаголовка,
	//	ПрефиксацияОбъектовКлиентСервер.НомерНаПечать(ДанныеДокументов.Номер),
	//	Формат(ДанныеДокументов.Дата, "ДЛФ=DD"));
	//ДанныеПечати.Вставить("ТекстЗаголовка", ТекстЗаголовка);
	
	ОбластьЗаголовокДокумента.Параметры.Заполнить(ДанныеДокументов);
	ТабличныйДокумент.Вывести(ОбластьЗаголовокДокумента);
	
КонецПроцедуры

Процедура ВывестиРеквизитыСторон(ДанныеДокументов, ТабличныйДокумент, Макет)
	
	ОбластьОтветственный = Макет.ПолучитьОбласть("ОбластьОтветственный");
	
	ДанныеПечати = Новый Структура;
	ДанныеПечати.Вставить("Ответственный", ДанныеДокументов.Ответственный);
		
	ОбластьОтветственный.Параметры.Заполнить(ДанныеПечати);
	ТабличныйДокумент.Вывести(ОбластьОтветственный);

	
КонецПроцедуры

Процедура ВывестиТоварыУслуги(ДанныеДокументов, ТабличныйДокумент, Макет)
	
	ОбластьШапкаТаблицы = Макет.ПолучитьОбласть("ОбластьТабЧасть");
	ОбластьСтрока = Макет.ПолучитьОбласть("ОбластьСтрока");
	ОбластьПодвал = Макет.ПолучитьОбласть("ОбластьИтог");
	
	ТабличныйДокумент.Вывести(ОбластьШапкаТаблицы);
	
	ВыборкаТовары = ДанныеДокументов.Товары.Выбрать();
	Пока ВыборкаТовары.Следующий() Цикл
		ОбластьСтрока.Параметры.Заполнить(ВыборкаТовары);
		ТабличныйДокумент.Вывести(ОбластьСтрока);
	КонецЦикла;
	
	ВыборкаУслуги = ДанныеДокументов.Услуги.Выбрать();
	Пока ВыборкаУслуги.Следующий() Цикл
		ОбластьСтрока.Параметры.Заполнить(ВыборкаУслуги);
		ТабличныйДокумент.Вывести(ОбластьСтрока);
	КонецЦикла;
	
	ДанныеПечати = Новый Структура;
	ДанныеПечати.Вставить("СуммаИтого", ДанныеДокументов.СуммаДокумента);
	
	ФормСтрока = "Л = ru_RU; ДП = Истина";
	ПарПредмета = "рубль, рубля, рублей, м, копейка, копеек, копеек, ж, 2";
	
	СуммаИтогПрописью = ЧислоПрописью(ДанныеДокументов.СуммаДокумента, ФормСтрока, ПарПредмета);
	
	ДанныеПечати.Вставить("СуммаИтогоПрописью", СуммаИтогПрописью);
	
	ОбластьПодвал.Параметры.Заполнить(ДанныеПечати);
	ТабличныйДокумент.Вывести(ОбластьПодвал);
	
КонецПроцедуры

#КонецОбласти
#КонецЕсли