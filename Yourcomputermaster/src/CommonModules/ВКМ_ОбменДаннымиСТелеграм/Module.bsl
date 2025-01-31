#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныйПрограммныйИнтерфейс

Функция ОтправкаЗаявкиБотТГ (Текст) Экспорт
	
	АдресСервера = "api.telegram.org";
	АдресРесурса = СтрШаблон("/bot%1/sendMessage", Константы.ВКМ_ТокенУправленияТелеграмБотом.Получить());
	
	Соединение = Новый HTTPСоединение(АдресСервера, , , , , 10, Новый ЗащищенноеСоединениеOpenSSL());
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-type", "application/json");
	
	СтруктураДанные = Новый Структура;
	СтруктураДанные.Вставить("chat_id", Константы.ВКМ_ИдентификаторГруппыОповещения.Получить());
	СтруктураДанные.Вставить("text", Текст);
	
	Запись = Новый ЗаписьJSON();
	Запись.УстановитьСтроку(Новый ПараметрыЗаписиJSON(, Символы.ПС));
	ЗаписатьJSON(Запись, СтруктураДанные);
	Результат = Запись.Закрыть();
	
	Запрос = Новый HTTPЗапрос(АдресРесурса, Заголовки);
	Запрос.УстановитьТелоИзСтроки(Результат);
	
	Попытка
		Ответ = Соединение.ОтправитьДляОбработки(Запрос);
	Исключение
		ЗаписьЖурналаРегистрации("Отправка сообщения в ТГ", , , , ОписаниеОшибки(), );
	КонецПопытки;
	
	Если Ответ.КодСостояния = 200 Тогда
		Возврат Истина;
	КонецЕсли;
	
	Возврат Ложь;
		
КонецФункции

Процедура ЧтениеСообщенийТГ() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ВКМ_УведомленияТелеграммБоту.ТекстСообщения,
	|	ВКМ_УведомленияТелеграммБоту.Ссылка
	|ИЗ
	|	Справочник.ВКМ_УведомленияТелеграммБоту КАК ВКМ_УведомленияТелеграммБоту";
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Результат = ОтправкаЗаявкиБотТГ(Выборка.ТекстСообщения);
		Если Результат Тогда
			СсылкаОбъекта = Выборка.Ссылка;
			Объект = СсылкаОбъекта.ПолучитьОбъект();
			Объект.Удалить();
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли