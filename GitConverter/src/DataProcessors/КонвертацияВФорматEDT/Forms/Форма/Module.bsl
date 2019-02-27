///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2017-2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by-sa/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОтключитьРегламентныеЗадания = Истина;
	ОтключитьКоммиты = Истина;
	ОтключитьОчереди = Истина;
	email = "anonimous@localhost";
	ИмяПользователя = "Anonimous";
	Комментарий = НСтр("ru = 'Конвертация в формат EDT'");
	
	Хранилище = Параметры.Хранилище;
	Если ЗначениеЗаполнено(Хранилище) Тогда
		ХранилищеПриИзмененииНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	МассивНеПроверяемыхРеквизитов = Новый Массив;
	
	СегментыПути = СтрРазделить(СокрЛП(ПутьКФайламПроектаEDT), ПолучитьРазделительПути());
	Если СегментыПути.Количество() > 0 И НЕ ЗначениеЗаполнено(СегментыПути[СегментыПути.ВГраница()]) Тогда
		СегментыПути.Удалить(СегментыПути.ВГраница());
	КонецЕсли;
	Путь = Новый Файл(ПутьКФайламПроектаEDT);
	
	Если СегментыПути.Количество() = 0 ИЛИ Путь.Существует() И НЕ Путь.ЭтоКаталог() Тогда
	
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Не верный путь к файлам EDT';");
		Сообщение.Сообщить();
		Отказ = Истина;
	
	КонецЕсли;
	
	Если СегментыПути.Количество() > 0 И СегментыПути[СегментыПути.ВГраница()] <> "src" Тогда
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'Необходимо указать каталог к исходным файлам src';");
		Сообщение.Сообщить();
		Отказ = Истина;
	КонецЕсли;
	
	Если НЕ Отказ И ЗначениеЗаполнено(Хранилище) Тогда
		КаталогВыгрузкиВРепозитории = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Хранилище, "КаталогВыгрузкиВРепозитории");
		СегментыПутиВРепозитории = СтрРазделить(СокрЛП(КаталогВыгрузкиВРепозитории), ПолучитьРазделительПути());

		Если ЗначениеЗаполнено(КаталогВыгрузкиВРепозитории)
				И СегментыПути.Количество() = 0 Тогда
			
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = НСтр("ru = 'Не корректный путь к каталога выгрузки в репозитории';");
			Сообщение.Сообщить();
			Отказ = Истина;
			
		КонецЕсли;

		Если НЕ Отказ И ЗначениеЗаполнено(КаталогВыгрузкиВРепозитории)
				И СегментыПутиВРепозитории.Количество() > 0 И СегментыПути.Количество() > 2
				И СегментыПути[СегментыПути.ВГраница()
				- 1] <> СегментыПутиВРепозитории[СегментыПутиВРепозитории.ВГраница()] Тогда
			
			Сообщение = Новый СообщениеПользователю();
			Сообщение.Текст = НСтр("ru = 'Каталог проекта EDT не совпадает с каталогом выгрузки';");
			Сообщение.Сообщить();
			Отказ = Истина;
			
		КонецЕсли;
	КонецЕсли;
 
	ОбщегоНазначения.УдалитьНепроверяемыеРеквизитыИзМассива(ПроверяемыеРеквизиты, МассивНеПроверяемыхРеквизитов);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ХранилищеПриИзменении(Элемент)
	
	ХранилищеПриИзмененииНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяПроектаEDTПриИзменении(Элемент)
	
	ИмяПроектаEDTПриИзмененииНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаКомандыGitОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если Не ЗначениеЗаполнено(ИмяФайлаКомандыGit) Тогда
		Возврат;
	КонецЕсли;
	
	Текст = Новый ТекстовыйДокумент();
	
	ИмяФайла = "";
	ПрочитатьТекстовыйФайлНаСервере(ИмяФайлаКомандыGit, Текст, ИмяФайла, Истина);
	
	Текст.Показать(ИмяФайла, ИмяФайла);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаКомментарияОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если Не ЗначениеЗаполнено(ИмяФайлаКомментария) Тогда
		Возврат;
	КонецЕсли;
	
	Текст = Новый ТекстовыйДокумент();
	
	ИмяФайла = "";
	
	ПрочитатьТекстовыйФайлНаСервере(ИмяФайлаКомментария, Текст, ИмяФайла);
	
	Текст.Показать(ИмяФайла, ИмяФайла);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаЛогаОткрытие(Элемент, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	Если Не ЗначениеЗаполнено(ИмяФайлаЛога) Тогда
		Возврат;
	КонецЕсли;
	
	Текст = Новый ТекстовыйДокумент();
	
	ИмяФайла = "";
	
	ПрочитатьТекстовыйФайлНаСервере(ИмяФайлаЛога, Текст, ИмяФайла);
	
	Текст.Показать(ИмяФайла, ИмяФайла);
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КонвертироватьВФорматEDT(Команда)
	
	Если НЕ ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	ВерсииEDT = ПолучитьДоступныеВерсииEDTНаСервере();
	ВерсияНайдена = Ложь;
	Для Каждого ВерсияEDT Из ВерсииEDT Цикл
		Если ВерсияПроектаEDT = ВерсияEDT Тогда
			ВерсияНайдена = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если НЕ ВерсияНайдена И ВерсииEDT.Количество() = 0 Тогда
		Текст = НСтр("ru = 'Не обнаружено доступных версий в 1C:EDT!
			|Возможно 1C:EDT версии 1.8 и выше не установлена на сервере или недоступна для запуска.'");
		ПоказатьПредупреждение(, Текст);
		Возврат;
	ИначеЕсли НЕ ВерсияНайдена Тогда
		Текст = НСтр("ru = 'Версия ''%Версия%'' не доступна для конвертации в формат 1C:EDT.
			|Укажите в настройках хранилища версию платформы из доступных: %ВерсииEDT%.'");
		Текст = СтрЗаменить(Текст, "%ВерсииEDT%", СтрСоединить(ВерсииEDT, ", "));
		Текст = СтрЗаменить(Текст, "%Версия%", ВерсияПроектаEDT);
		ПоказатьПредупреждение(, Текст);
		Возврат;
	КонецЕсли;
	
	КонвертироватьВФорматEDTНаСервере();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура КонвертироватьВФорматEDTНаСервере()
	
	ОтключитьХранилище();
	
	РеквизитыХранилища = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Хранилище, "КаталогВыгрузкиВерсий, 
		|ЛокальныйКаталогGit, КаталогВыгрузкиВРепозитории, АдресРепозиторияGit, ИмяВетки");
	
	ПутьКИсходнымФайлам = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(РеквизитыХранилища.ЛокальныйКаталогGit);
	
	ПутьКИсходнымФайлам = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПутьКИсходнымФайлам
		+ КонвертацияХранилища.КаталогВыгрузкиВРепозитории(РеквизитыХранилища));
	Файл = Новый Файл(ПутьКИсходнымФайлам);
	Если Не Файл.Существует() Тогда
		Возврат;
	КонецЕсли;
	
	ЭтоWindowsСервер = ОбщегоНазначенияПовтИсп.ЭтоWindowsСервер();
		
	СформироватьИменаФайлов(РеквизитыХранилища.КаталогВыгрузкиВерсий, ЭтоWindowsСервер);
	
	ЗаписатьФайлыКонвертации(РеквизитыХранилища, ЭтоWindowsСервер);
	
	КодВозврата = Неопределено;
	ЗапуститьПриложение(?(ЭтоWindowsСервер, "", "bash ")
		+ ИмяФайлаКомандыGit, РеквизитыХранилища.ЛокальныйКаталогGit, Истина, КодВозврата);
	
	Если КодВозврата = 0 Тогда
		ХранилищеОбъект = Хранилище.ПолучитьОбъект();
		ХранилищеОбъект.КонвертироватьВФорматEDT = Истина;
		Если ВыполнитьПереносВКаталогПроекта 
			И НЕ ЗначениеЗаполнено(РеквизитыХранилища.КаталогВыгрузкиВРепозитории) 
			И ЗначениеЗаполнено(ИмяПроектаEDT) Тогда
			ХранилищеОбъект.КаталогВыгрузкиВРепозитории = ИмяПроектаEDT;
		КонецЕсли;
		ХранилищеОбъект.Записать();
	Иначе
		Сообщение = Новый СообщениеПользователю();
		Сообщение.Текст = НСтр("ru = 'В процессе конвертации произошли ошибки.  См. файл лога.'");
		Сообщение.Сообщить();
	КонецЕсли;
	
КонецПроцедуры

// Формирует имена файлов для конвертации
// 
// Параметры:
// 	КаталогВыгрузкиВерсий - Строка - Каталог выгрузки версий проекта
// 	ЭтоWindowsСервер - Булево - признак ОС Windows
&НаСервере
Процедура СформироватьИменаФайлов(КаталогВыгрузкиВерсий, ЭтоWindowsСервер)
		
	ИмяФайлаЛога = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(КаталогВыгрузкиВерсий)
		+ "git_convert_to_edt_log" + ".txt";
	ИмяФайлаКомандыGit = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(КаталогВыгрузкиВерсий)
		+ "git_convert_to_edt" + ?(ЭтоWindowsСервер, ".bat", ".sh");
	ИмяФайлаКомментария = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(КаталогВыгрузкиВерсий)
		+ "git_convert_to_edt_comment" + ".txt";
	
КонецПроцедуры

&НаСервере
Процедура ХранилищеПриИзмененииНаСервере()
	
	Если ЗначениеЗаполнено(Хранилище) Тогда
		ЭтоWindowsСервер = ОбщегоНазначенияПовтИсп.ЭтоWindowsСервер();
		
		РеквизитыХранилища = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Хранилище,
			"ВерсияПлатформы, 
			|КаталогВыгрузкиВерсий,
			|КаталогВыгрузкиВРепозитории,
			|ВерсияEDT");
		
		РеквизитыХранилища.КаталогВыгрузкиВерсий = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(РеквизитыХранилища.КаталогВыгрузкиВерсий);
		СформироватьИменаФайлов(РеквизитыХранилища.КаталогВыгрузкиВерсий, ЭтоWindowsСервер);
		
		Объект.ВерсияEDT = РеквизитыХранилища.ВерсияEDT;
		ВерсияПроектаEDT = "";
		Версия = РеквизитыХранилища.ВерсияПлатформы;
		Если НЕ ЗначениеЗаполнено(Версия) Тогда
			СисИнфо = Новый СистемнаяИнформация();
			Версия = СисИнфо.ВерсияПриложения;
		КонецЕсли;
		Квалификаторы = СтрРазделить(Версия, ".");
		Если Квалификаторы.Количество() = 4 Тогда
			Квалификаторы.Удалить(Квалификаторы.ВГраница());
			Версия = СтрСоединить(Квалификаторы, ".");
			ВерсииEDT = КонвертацияХранилища.ПолучитьСписокВерсийПлатформыEDT(Объект.ВерсияEDT);
			Для Каждого ВерсияEDT Из ВерсииEDT Цикл
				Если Версия = ВерсияEDT Тогда
					ВерсияПроектаEDT = ВерсияEDT;
					Прервать;
				КонецЕсли;
			КонецЦикла;
			
		КонецЕсли;
		
		ИмяПроектаEDT = "";
		Если ЗначениеЗаполнено(РеквизитыХранилища.КаталогВыгрузкиВРепозитории) Тогда
			Сегменты = СтрРазделить(РеквизитыХранилища.КаталогВыгрузкиВРепозитории, ПолучитьРазделительПути());
			Если Сегменты.Количество() > 0 Тогда
				ИмяПроектаEDT = Сегменты[Сегменты.ВГраница()];
			КонецЕсли;
		КонецЕсли;
		
		КаталогВыгрузкиВерсий = РеквизитыХранилища.КаталогВыгрузкиВерсий;
		
		РабочийКаталогEDT = КаталогВыгрузкиВерсий + "ws";
		
		ВыполнитьПереносВКаталогПроекта = НЕ ЗначениеЗаполнено(РеквизитыХранилища.КаталогВыгрузкиВРепозитории);
		
		Элементы.ВыполнитьПереносВКаталогПроекта.Видимость = ВыполнитьПереносВКаталогПроекта;
		
	Иначе
		ИмяФайлаКомандыGit = "";
		ИмяФайлаКомментария = "";
		ИмяФайлаЛога = "";
		ВерсияПроектаEDT = "";
		ИмяПроектаEDT = "";
		КаталогВыгрузкиВерсий = "";
		РабочийКаталогEDT = "";
		ВыполнитьПереносВКаталогПроекта = Ложь;
		
		Элементы.ВыполнитьПереносВКаталогПроекта.Видимость = Ложь;
	КонецЕсли;
	
	ИмяПроектаEDTПриИзмененииНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура ИмяПроектаEDTПриИзмененииНаСервере()
	
	ПутьКПроектуEDT = "";
	ПутьКФайламПроектаEDT = "";
	Если ЗначениеЗаполнено(ИмяПроектаEDT) Тогда
		ПутьКПроектуEDT = КаталогВыгрузкиВерсий + "p"
			+ ПолучитьРазделительПути() + ИмяПроектаEDT + ПолучитьРазделительПути();
		ПутьКФайламПроектаEDT = ПутьКПроектуEDT + "src"
	КонецЕсли;
		
КонецПроцедуры

&НаСервере
Процедура ОтключитьХранилище()
	
	ЕстьНеОбработанныеВерсии = Ложь;
	
	// Сбрасываем статус загруженных версий - их необходимо сконвертировать в формат EDT
	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	ВерсииХранилища.Ссылка
		|ИЗ
		|	Справочник.ВерсииХранилища КАК ВерсииХранилища
		|ГДЕ
		|	ВерсииХранилища.Владелец = &Хранилище
		|	И (ВерсииХранилища.Состояние = ЗНАЧЕНИЕ(Перечисление.СостоянияВерсии.ЗагрузкаМетаданных)
		|	ИЛИ ВерсииХранилища.Состояние = ЗНАЧЕНИЕ(Перечисление.СостоянияВерсии.МетаданныеЗагружены))";
	
	Запрос.УстановитьПараметр("Хранилище", Хранилище);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		ВерсияОбъект = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
		ВерсияОбъект.Состояние = Перечисления.СостоянияВерсии.ВерсияПолучена;
		ВерсияОбъект.Записать();
		ЕстьНеОбработанныеВерсии = Истина;
	КонецЦикла;
	
	Если ЕстьНеОбработанныеВерсии Тогда
		ОтключитьОчереди = Истина;
		ОтключитьРегламентныеЗадания = Истина;
		ОтключитьКоммиты = Истина;
	КонецЕсли;
	
	ХранилищеОбъект = Хранилище.ПолучитьОбъект();
	
	Если ОтключитьКоммиты Тогда
		ХранилищеОбъект.ВыполнятьКоммиты = Ложь;
	КонецЕсли;
	
	Если ОтключитьОчереди Тогда
		ХранилищеОбъект.ОбрабатыватьВсеОчереди = Ложь;
		ХранилищеОбъект.ЗапретитьИспользованиеОбщихОчередей = Истина;
	КонецЕсли;
	
	Если ОтключитьРегламентныеЗадания Тогда
		ХранилищеОбъект.ДополнительныеСвойства.Вставить("Использование", Ложь);
	КонецЕсли;
	ХранилищеОбъект.Записать();
	Если ОтключитьРегламентныеЗадания Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст =
			"ВЫБРАТЬ
			|	КопииХранилищКонфигурации.Ссылка
			|ИЗ
			|	Справочник.КопииХранилищКонфигурации КАК КопииХранилищКонфигурации
			|ГДЕ
			|	КопииХранилищКонфигурации.Владелец = &Хранилище
			|ОБЪЕДИНИТЬ ВСЕ
			|ВЫБРАТЬ
			|	ОчередиВыполнения.Ссылка
			|ИЗ
			|	Справочник.ОчередиВыполнения КАК ОчередиВыполнения
			|ГДЕ
			|	ОчередиВыполнения.Хранилище = &Хранилище";
		
		Запрос.УстановитьПараметр("Хранилище", Хранилище);
		
		РезультатЗапроса = Запрос.Выполнить();
		
		ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
		
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			ЗаданиеОбъект = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();
			ЗаданиеОбъект.ДополнительныеСвойства.Вставить("Использование", Ложь);
			ЗаданиеОбъект.Записать();
		КонецЦикла;
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗаписатьФайлыКонвертации(РеквизитыХранилища, ЭтоWindowsСервер)
	
	ПутьКФайламПроектаEDT = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(СокрЛП(ПутьКФайламПроектаEDT));
	ЛокальныйКаталогGit = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(РеквизитыХранилища.ЛокальныйКаталогGit);
	
	ДлиннаПути = СтрДлина(ЛокальныйКаталогGit);
	
	ПутьКИсходнымФайлам = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ЛокальныйКаталогGit
		+ КонвертацияХранилища.КаталогВыгрузкиВРепозитории(РеквизитыХранилища));
	Файл = Новый Файл(ПутьКИсходнымФайлам);
	Если Не Файл.Существует() Тогда
		Возврат;
	КонецЕсли;
	
	ФайлКоманды = Новый ТекстовыйДокумент;

	Если ЭтоWindowsСервер Тогда
		ТекстКоманды = "@ECHO OFF";
		ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
	Иначе
		ТекстКоманды = "#!/bin/bash";
		ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
	КонецЕсли;

	ТекстКоманды = ?(ЭтоWindowsСервер, "set ", "") + "LOGFILE=""%ФайлЛога%""";
	ТекстКоманды = СтрЗаменить(ТекстКоманды, "%ФайлЛога%", ИмяФайлаЛога);
	ФайлКоманды.ДобавитьСтроку(ТекстКоманды);

	Если ЭтоWindowsСервер Тогда
		ВыводЛога = " >> %LOGFILE% 2>&1";
		ПроверкаКодаВозврата = "echo Error level: %ERRORLEVEL%" + ВыводЛога + "
		|IF %ERRORLEVEL% NEQ 0 THEN exit %ERRORLEVEL%" + ВыводЛога;
	Иначе
		ВыводЛога = " >> $LOGFILE 2>&1";
		ПроверкаКодаВозврата = "echo ""Error level: $?""" + ВыводЛога + "
		|if [ $? -ne 0 ]; then exit $? fi" + ВыводЛога;
	КонецЕсли;
	
	// Запуск RING EDT для конвертацию в формат EDT
	СтрокаКоманды = ?(ЭтоWindowsСервер, "call ", "")
		+ "ring edt workspace import --workspace-location ""%РабочийКаталог%"" --configuration-files ""%КаталогФайловКонфигурации%"" --project ""%КаталогПроектаEDT%"" --version %ВерсияПроектаEDT%" + ВыводЛога;
	
	КонвертацияХранилища.УстановитьВерсиюEDT(СтрокаКоманды, Объект.ВерсияEDT);
	
	СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%ИмяФайлаЛогов%", ИмяФайлаЛога);
	Если Прав(РабочийКаталогEDT, 1) = ПолучитьРазделительПути() Тогда
		РабочийКаталогEDT = Лев(РабочийКаталогEDT, СтрДлина(РабочийКаталогEDT)-1);
	КонецЕсли;
	СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%РабочийКаталог%", РабочийКаталогEDT);
	Если Прав(ПутьКИсходнымФайлам, 1) = ПолучитьРазделительПути() Тогда
		СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%КаталогФайловКонфигурации%", Лев(ПутьКИсходнымФайлам, СтрДлина(ПутьКИсходнымФайлам)-1));
	Иначе
		СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%КаталогФайловКонфигурации%", ПутьКИсходнымФайлам);
	КонецЕсли;
	
	Если Прав(ПутьКПроектуEDT, 1) = ПолучитьРазделительПути() Тогда
		СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%КаталогПроектаEDT%", Лев(ПутьКПроектуEDT, СтрДлина(ПутьКПроектуEDT)-1));
	Иначе
		СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%КаталогПроектаEDT%", ПутьКПроектуEDT);
	КонецЕсли;
	
	СтрокаКоманды = СтрЗаменить(СтрокаКоманды, "%ВерсияПроектаEDT%", ВерсияПроектаEDT);
	ФайлКоманды.ДобавитьСтроку(СтрокаКоманды);
	
	ФайлКоманды.ДобавитьСтроку(ПроверкаКодаВозврата);

	Файл = Новый Файл(РабочийКаталогEDT);
	Если Файл.Существует() Тогда
		УдалитьФайлы(РабочийКаталогEDT, "*");
	КонецЕсли;
	Файл = Новый Файл(ПутьКПроектуEDT);
	Если Файл.Существует() Тогда
		УдалитьФайлы(ПутьКПроектуEDT, "*");
	КонецЕсли;
	
	Если ЭтоWindowsСервер Тогда
		ТекстКомандыУстановкиКаталога = "cd /D ""%ЛокальныйКаталогGit%""" + ВыводЛога;
	Иначе
		ТекстКомандыУстановкиКаталога = "cd ""%ЛокальныйКаталогGit%""" + ВыводЛога;
	КонецЕсли;
	ТекстКомандыУстановкиКаталога = СтрЗаменить(ТекстКомандыУстановкиКаталога, "%ЛокальныйКаталогGit%", 
		РеквизитыХранилища.ЛокальныйКаталогGit);

	Если ВыполнитьPushПослеКонвертации И ЗначениеЗаполнено(РеквизитыХранилища.АдресРепозиторияGit) Тогда
		ТекстКоманды = "git pull" + ВыводЛога;
		ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
	КонецЕсли;
	
	ФайлКоманды.ДобавитьСтроку(ПроверкаКодаВозврата);
	
	Переименования = Новый ТаблицаЗначений();
	Переименования.Колонки.Добавить("Источник");
	Переименования.Колонки.Добавить("Приемник");
	
	РазделительПути = ПолучитьРазделительПути();
	
	// Если отсутствует имя проекта EDT в хранилище - добавляем префикс имя проекта
	ПрефиксПриемника = "";
	Если ВыполнитьПереносВКаталогПроекта 
		И НЕ ЗначениеЗаполнено(РеквизитыХранилища.КаталогВыгрузкиВРепозитории) 
		И ЗначениеЗаполнено(ИмяПроектаEDT) Тогда
		ПрефиксПриемника = ИмяПроектаEDT + РазделительПути;
	КонецЕсли;
	ШаблонExt = РазделительПути + "Ext" + РазделительПути;
	
	// Перемещение файлов корня конфигурации
	ПутьПоиска = ПутьКИсходнымФайлам + "Ext" + РазделительПути;
	Файлы = НайтиФайлы(ПутьПоиска, "*", Истина);
	Для Каждого Файл Из Файлы Цикл
		Если Файл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;
		Источник = Сред(Файл.ПолноеИмя, ДлиннаПути);
		Приемник = СтрЗаменить(Источник, ШаблонExt, РазделительПути + "Configuration" + РазделительПути);
		
		Если Файл.Имя = "ClientApplicationInterface.xml" Тогда
			Приемник = СтрЗаменить(Приемник, "ClientApplicationInterface.xml", "ClientApplicationInterface.cai");
		ИначеЕсли Файл.Имя = "CommandInterface.xml" Тогда
			Приемник = СтрЗаменить(Приемник, "CommandInterface.xml", "CommandInterface.cmi");
		ИначеЕсли Файл.Имя = "HomePageWorkArea.xml" Тогда
			Приемник = СтрЗаменить(Приемник, "HomePageWorkArea.xml", "HomePageWorkArea.hpwa");
		ИначеЕсли Файл.Имя = "MainSectionCommandInterface.xml" Тогда
			Приемник = СтрЗаменить(Приемник, "MainSectionCommandInterface.xml", "MainSectionCommandInterface.cmi");
		ИначеЕсли Файл.Имя = "Picture.png" И (СтрНайти(Приемник, "MainSectionPicture") > 0 ИЛИ СтрНайти(Приемник, "Splash") > 0) Тогда
			Приемник = СтрЗаменить(Приемник, РазделительПути + "Picture", "");
		КонецЕсли;
		
		НоваяСтрока = Переименования.Добавить();
		НоваяСтрока.Источник = Источник;
		НоваяСтрока.Приемник = ПрефиксПриемника + Приемник;
		
	КонецЦикла;
	
	Файл = Новый Файл(ПутьКИсходнымФайлам + "Configuration.xml");
	Если Файл.Существует() Тогда
		НоваяСтрока = Переименования.Добавить();
		НоваяСтрока.Источник = Сред(Файл.ПолноеИмя, ДлиннаПути);
		НоваяСтрока.Приемник = ПрефиксПриемника + СтрЗаменить(НоваяСтрока.Источник, "Configuration.xml", "Configuration" + РазделительПути + "Configuration.mdo");
	КонецЕсли;
	
	СоответствиеТиповМакетов = СоответствиеТиповМакетов();
	
	// Перемещение всех поддерживаемых типов
	Для Каждого Контейнер Из ПоддерживаемыеКонтейнеры() Цикл
		ПутьПоиска = ПутьКИсходнымФайлам + Контейнер + РазделительПути;
		Файлы = НайтиФайлы(ПутьПоиска, "*", Истина);
		
		Для Каждого Файл Из Файлы Цикл
			Если Файл.ЭтоКаталог() Тогда
				Продолжить;
			КонецЕсли;
			
			Источник = Сред(Файл.ПолноеИмя, ДлиннаПути);
			Приемник = СтрЗаменить(Источник, ШаблонExt, РазделительПути);
			
			Если Файл.Имя = "Form.xml" Тогда
				Приемник = СтрЗаменить(Приемник, Файл.Имя, "Form.form");
			ИначеЕсли Файл.Имя = "Module.bsl" И СтрНайти(Приемник, РазделительПути + "Form" + РазделительПути + Файл.Имя) > 0 Тогда 
				Приемник = СтрЗаменить(Приемник, РазделительПути + "Form" + РазделительПути + Файл.Имя, РазделительПути + Файл.Имя);
			ИначеЕсли Файл.Имя = "Template.xml" Тогда
				ИмяФайлаМакета = Файл.ПолноеИмя;
				СегментыИмени = СтрРазделить(ИмяФайлаМакета, РазделительПути);
				Если СегментыИмени.Количество() > 3 Тогда
					СегментыИмени.Удалить(СегментыИмени.ВГраница()); // Имя файла Template.xml
					СегментыИмени.Удалить(СегментыИмени.ВГраница()); // Каталог Ext
					ИмяФайлаМакета = СтрСоединить(СегментыИмени, РазделительПути) + ".xml";
					ТипМакета = ПрочитатьТипМакета(ИмяФайлаМакета);
					Расширение = "";
					Если ЗначениеЗаполнено(ТипМакета) И СоответствиеТиповМакетов.Свойство(ТипМакета, Расширение) Тогда
						Приемник = СтрЗаменить(Приемник, Файл.Имя, "Template." + Расширение);
					КонецЕсли;
				КонецЕсли;
			ИначеЕсли Файл.Имя = "Package.bin" И Контейнер = "XDTOPackages" Тогда
				Приемник = СтрЗаменить(Приемник, Файл.Имя, "Package.xdto");
			ИначеЕсли Файл.Имя = "WSDefinition.xml" И Контейнер = "WSReferences" Тогда
				Приемник = СтрЗаменить(Приемник, Файл.Имя, "WsDefinitions.wsdl");
			ИначеЕсли Файл.Имя = "Flowchart.xml" И Контейнер = "BusinessProcesses" Тогда
				Приемник = СтрЗаменить(Приемник, Файл.Имя, "Flowchart.scheme");
			ИначеЕсли Файл.Имя = "Rights.xml" И Контейнер = "Roles" Тогда
				Приемник = СтрЗаменить(Приемник, Файл.Имя, "Rights.rights");
			ИначеЕсли Файл.Расширение = ".xml" И Файл.ПолноеИмя = ПутьПоиска + Файл.Имя Тогда
				Приемник = СтрЗаменить(Приемник, Файл.Имя, Файл.ИмяБезРасширения + РазделительПути + Файл.ИмяБезРасширения + ".mdo");
			ИначеЕсли Файл.ИмяБезРасширения = "Picture" И Контейнер = "CommonPictures" 
				И СтрНайти(Приемник, РазделительПути + Файл.ИмяБезРасширения + РазделительПути + Файл.ИмяБезРасширения) > 0 Тогда
				Приемник = СтрЗаменить(Приемник, РазделительПути + Файл.ИмяБезРасширения + РазделительПути + Файл.ИмяБезРасширения, РазделительПути + Файл.ИмяБезРасширения);
			ИначеЕсли Файл.Имя = "Schedule.xml" И Контейнер = "ScheduledJobs" Тогда
				Приемник = СтрЗаменить(Приемник, Файл.Имя, "Schedule.schedule");
			КонецЕсли;
			
			Приемник = ПрефиксПриемника + Приемник;
			Если Источник <> Приемник Тогда
				НоваяСтрока = Переименования.Добавить();
				НоваяСтрока.Источник = Источник;
				НоваяСтрока.Приемник = Приемник;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	// Перемещение подсистем
	ПутьПоиска = ПутьКИсходнымФайлам + "Subsystems" + РазделительПути;
	Файлы = НайтиФайлы(ПутьПоиска, "*", Истина);
	Для Каждого Файл Из Файлы Цикл
		Если Файл.ЭтоКаталог() Тогда
			Продолжить;
		КонецЕсли;
		Источник = Сред(Файл.ПолноеИмя, ДлиннаПути);
		Приемник = СтрЗаменить(Источник, ШаблонExt, РазделительПути);

		Если Файл.Расширение = ".xml" И Файл.Имя <> "CommandInterface.xml" И Файл.Имя <> "Help.xml" Тогда
			Приемник = СтрЗаменить(Приемник, Файл.Имя, Файл.ИмяБезРасширения + РазделительПути + Файл.ИмяБезРасширения + ".mdo");
		ИначеЕсли Файл.Имя = "CommandInterface.xml" Тогда
			Приемник = СтрЗаменить(Приемник, "CommandInterface.xml", "CommandInterface.cmi");
		КонецЕсли;
		
		Приемник = ПрефиксПриемника + Приемник;
		Если Источник <> Приемник Тогда
			НоваяСтрока = Переименования.Добавить();
			НоваяСтрока.Источник = Источник;
			НоваяСтрока.Приемник = Приемник;
		КонецЕсли;
	КонецЦикла;
	
	// Перемещение неподдерживаемых метаданных в директорию unknown
	ШаблонSRC = РазделительПути + "src" + РазделительПути;
	ЗаменаSRC = РазделительПути + "unknown" + РазделительПути;
	
	Для Каждого Контейнер Из НеПоддерживаемыеКонтейнеры() Цикл
		ПутьПоиска = ПутьКИсходнымФайлам + Контейнер + РазделительПути;
		Файлы = НайтиФайлы(ПутьПоиска, "*", Истина);
		
		Для Каждого Файл Из Файлы Цикл
			Если Файл.ЭтоКаталог() Тогда
				Продолжить;
			КонецЕсли;
			
			Источник = Сред(Файл.ПолноеИмя, ДлиннаПути);
			Приемник = СтрЗаменить(Источник, ШаблонSRC, ЗаменаSRC);
			
			Приемник = ПрефиксПриемника + Приемник;
			Если Источник <> Приемник Тогда
				НоваяСтрока = Переименования.Добавить();
				НоваяСтрока.Источник = Источник;
				НоваяСтрока.Приемник = Приемник;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Каталоги = Новый Соответствие();
	
	Для Каждого Переименование Из Переименования Цикл
		ТекстКоманды = "git mv -f "".%Источник%"" "".%Приемник%""" + ВыводЛога;

		ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Источник%", Переименование.Источник);
		ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", Переименование.Приемник);
		ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
		
		Сегменты = СтрРазделить(Переименование.Приемник, РазделительПути);
		Если Сегменты.Количество()  > 2 Тогда
			Сегменты.Удалить(Сегменты.ВГраница());
			Каталоги.Вставить(СтрСоединить(Сегменты, РазделительПути), Сегменты);
		КонецЕсли;
	КонецЦикла;
	
	// Создать все отсутствующие директории в src
	Для Каждого КлючИЗначение Из Каталоги Цикл
		Каталог = Новый Файл(ЛокальныйКаталогGit + КлючИЗначение.Ключ);
		Если НЕ Каталог.Существует() Тогда
			СоздатьКаталогиРекурсивно(ЛокальныйКаталогGit, КлючИЗначение.Значение, РазделительПути);
		КонецЕсли;
	КонецЦикла;
	
	ТекстКоманды = "git commit -F ""%ИмяФайлаКомментария%"" --allow-empty-message --cleanup=verbatim" + ВыводЛога;
	ТекстКоманды = СтрЗаменить(ТекстКоманды, "%ИмяФайлаКомментария%", ИмяФайлаКомментария);
	ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
	
	Если ВыполнитьПереносВКаталогПроекта Тогда
		НовыеПараметры = Новый Структура("КаталогВыгрузкиВРепозитории", ИмяПроектаEDT);
		ПутьКИсходнымФайлам = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ЛокальныйКаталогGit
			+ КонвертацияХранилища.КаталогВыгрузкиВРепозитории(НовыеПараметры));
	КонецЕсли;
	
	ФайлКоманды.ДобавитьСтроку(ПроверкаКодаВозврата);
	
	// Удаляем исходную директорию src и копируем все файлы из EDT
	Если ЭтоWindowsСервер Тогда
		ТекстКоманды = "rmdir /S /Q ""%Приемник%""" + ВыводЛога;
		ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", ПутьКИсходнымФайлам);
		ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
		ТекстКоманды = "mkdir ""%Приемник%""" + ВыводЛога;
		ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", ПутьКИсходнымФайлам);
		ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
		Источник = СокрЛП(ПутьКФайламПроектаEDT);
		Если Прав(Источник, 1) = ПолучитьРазделительПути() Тогда
			Источник = Лев(Источник, СтрДлина(Источник) - 1);
		КонецЕсли;
		Приемник = СокрЛП(ПутьКИсходнымФайлам);
		Если Прав(Приемник, 1) = ПолучитьРазделительПути() Тогда
			Приемник = Лев(Приемник, СтрДлина(Приемник) - 1);
		КонецЕсли;
		ТекстКоманды = "robocopy ""%Источник%"" ""%Приемник%"" /E  /NFL /NDL /NJH /NJS /NC /NS /NP" + ВыводЛога;
		ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Источник%", Источник);
		ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", Приемник);
		ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
	Иначе
		ТекстКоманды = "rm -rf ""%Приемник%""" + ВыводЛога;
		ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", ПутьКИсходнымФайлам);
		ФайлКоманды.ДобавитьСтроку(ТекстКоманды);

		ТекстКоманды = "cp -Rf ""%Источник%"" ""%Приемник%""" + ВыводЛога;
		ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Источник%", ПутьКФайламПроектаEDT);
		ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", ПутьКИсходнымФайлам);
		ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
	КонецЕсли;
	
	// Копирование файла проекта, DT-INF и настроек
	Если ВыполнитьПереносВКаталогПроекта ИЛИ ЗначениеЗаполнено(РеквизитыХранилища.КаталогВыгрузкиВРепозитории) Тогда
		ПутьКПроекту = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(РеквизитыХранилища.ЛокальныйКаталогGit);
		Если ЗначениеЗаполнено(РеквизитыХранилища.КаталогВыгрузкиВРепозитории) Тогда
			ПутьКПроекту = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПутьКПроекту
				+ РеквизитыХранилища.КаталогВыгрузкиВРепозитории);
		Иначе
			ПутьКПроекту = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПутьКПроекту
				+ ИмяПроектаEDT);
		КонецЕсли;
		
		Если ЭтоWindowsСервер Тогда
			ТекстКоманды = "copy /Y ""%Источник%"" ""%Приемник%""" + ВыводЛога;
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Источник%", ПутьКПроектуEDT + ".project");
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", ПутьКПроекту + ".project");
			ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
			ТекстКоманды = "robocopy ""%Источник%"" ""%Приемник%"" /E  /NFL /NDL /NJH /NJS /NC /NS /NP" + ВыводЛога;
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Источник%", ПутьКПроектуEDT + ".settings");
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", ПутьКПроекту + ".settings");
			ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
			ТекстКоманды = "robocopy ""%Источник%"" ""%Приемник%"" /E  /NFL /NDL /NJH /NJS /NC /NS /NP" + ВыводЛога;
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Источник%", ПутьКПроектуEDT + "DT-INF");
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", ПутьКПроекту + "DT-INF");
			ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
		Иначе
			ТекстКоманды = "cp -f ""%Источник%"" ""%Приемник%""" + ВыводЛога;
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Источник%", ПутьКПроектуEDT + ".project");
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", ПутьКПроекту + ".project");
			ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
			ТекстКоманды = "cp -Rf ""%Источник%"" ""%Приемник%""" + ВыводЛога;
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Источник%", ПутьКПроектуEDT + ".settings" + РазделительПути);
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", ПутьКПроекту + ".settings" + РазделительПути);
			ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
			ТекстКоманды = "cp -Rf ""%Источник%"" ""%Приемник%""" + ВыводЛога;
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Источник%", ПутьКПроектуEDT + "DT-INF" + РазделительПути);
			ТекстКоманды = СтрЗаменить(ТекстКоманды, "%Приемник%", ПутьКПроекту + "DT-INF" + РазделительПути);
			ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
		КонецЕсли;
	КонецЕсли;
	
	
	// Все файлы новой версии добавляем в индекс
	ТекстКоманды = "git add --all ./" + ВыводЛога;
	ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
	
	ТекстКоманды = "git commit -F ""%ИмяФайлаКомментария%"" --allow-empty-message --cleanup=verbatim" + ВыводЛога;
	ТекстКоманды = СтрЗаменить(ТекстКоманды, "%ИмяФайлаКомментария%", ИмяФайлаКомментария);
	ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
	
	ФайлКоманды.ДобавитьСтроку(ПроверкаКодаВозврата);
	
	ФайлКомментария = Новый ТекстовыйДокумент;
	ФайлКомментария.УстановитьТекст(Комментарий);
	ФайлКомментария.Записать(ИмяФайлаКомментария, КодировкаТекста.UTF8);

	// Выполнение регламентных действий с репозиторием, если необходимо
	ТекстКоманды = "git gc --auto" + ВыводЛога;
	ФайлКоманды.ДобавитьСтроку(ТекстКоманды);

	Если ВыполнитьPushПослеКонвертации И ЗначениеЗаполнено(РеквизитыХранилища.АдресРепозиторияGit) Тогда
		ТекстКоманды = "git push -u origin %ИмяВетки%" + ВыводЛога;
		ТекстКоманды = СтрЗаменить(ТекстКоманды, "%ИмяВетки%", РеквизитыХранилища.ИмяВетки);
		ФайлКоманды.ДобавитьСтроку(ТекстКоманды);
		
		ФайлКоманды.ДобавитьСтроку(ПроверкаКодаВозврата);
	КонецЕсли;

	Если ЭтоWindowsСервер Тогда
		ФайлКоманды.Записать(ИмяФайлаКомандыGit, КодировкаТекста.OEM);
	Иначе
		ФайлКоманды.Записать(ИмяФайлаКомандыGit, КодировкаТекста.Системная);
	КонецЕсли;
	
	
КонецПроцедуры

&НаСервере
Функция ПолучитьДоступныеВерсииEDTНаСервере()
	
	Возврат КонвертацияХранилища.ПолучитьСписокВерсийПлатформыEDT(Объект.ВерсияEDT);
		
КонецФункции

// Создание отсутствующих каталогов рекурсивно
// 
// Параметры:
// 	ЛокальныйКаталогGit - Начальный каталог проверки
// 	Сегменты - Массив - Сегменты пути в репозитории
// 	РазделительПути - Строка - Разделитель пути
&НаСервере
Процедура СоздатьКаталогиРекурсивно(ЛокальныйКаталогGit, Сегменты, РазделительПути)
	Путь = ЛокальныйКаталогGit;
	Для Каждого Сегмент Из Сегменты Цикл
		Если НЕ ЗначениеЗаполнено(Сегмент) Тогда
			Продолжить;
		КонецЕсли;
		Путь = Путь + Сегмент + РазделительПути;
		Каталог = Новый Файл(Путь);
		Если НЕ Каталог.Существует() Тогда
			СоздатьКаталог(Путь);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

// Состав поддерживаемых контейнеров конфигурации
// 
// Параметры:
// Возвращаемое значение:
// 	Массив - список контейнеров
&НаСервере
Функция ПоддерживаемыеКонтейнеры()
	
	Состав = Новый Массив;
	Состав.Добавить("AccountingRegisters");
	Состав.Добавить("AccumulationRegisters");
	Состав.Добавить("CalculationRegisters");
	Состав.Добавить("BusinessProcesses");
	Состав.Добавить("Catalogs");
	Состав.Добавить("ChartsOfAccounts");
	Состав.Добавить("ChartsOfCalculationTypes");
	Состав.Добавить("ChartsOfCharacteristicTypes");
	Состав.Добавить("CommandGroups");
	Состав.Добавить("CommonAttributes");
	Состав.Добавить("CommonCommands");
	Состав.Добавить("CommonForms");
	Состав.Добавить("CommonModules");
	Состав.Добавить("CommonPictures");
	Состав.Добавить("CommonTemplates");
	Состав.Добавить("Constants");
	Состав.Добавить("DataProcessors");
	Состав.Добавить("DefinedTypes");
	Состав.Добавить("DocumentJournals");
	Состав.Добавить("DocumentNumerators");
	Состав.Добавить("Documents");
	Состав.Добавить("Enums");
	Состав.Добавить("EventSubscriptions");
	Состав.Добавить("ExchangePlans");
	Состав.Добавить("FilterCriteria");
	Состав.Добавить("FunctionalOptions");
	Состав.Добавить("FunctionalOptionsParameters");
	Состав.Добавить("HTTPServices");
	Состав.Добавить("InformationRegisters");
	//Состав.Добавить("Languages"); // Перемещается в Configuration.mdo
	Состав.Добавить("Reports");
	Состав.Добавить("Roles");
	Состав.Добавить("ScheduledJobs");
	Состав.Добавить("SessionParameters");
	Состав.Добавить("SettingsStorages");
	Состав.Добавить("Sequences");
	Состав.Добавить("StyleItems");
	//Состав.Добавить("Subsystems"); // Обрабатывается отдельно
	Состав.Добавить("Tasks");
	Состав.Добавить("XDTOPackages");
	Состав.Добавить("WSReferences");
	Состав.Добавить("WebServices");

	Возврат Состав;
КонецФункции


// Состав не поддерживаемых контейнеров конфигурации
// 
// Возвращаемое значение:
// 	Массив - список контейнеров
&НаСервере
Функция НеПоддерживаемыеКонтейнеры()

	Состав = Новый Массив;
	Состав.Добавить("ExternalDataSources");
	Состав.Добавить("Interfaces");
	Состав.Добавить("Styles");

	Возврат Состав;
КонецФункции

// Соответствие типов макетов и расширений файлов Template.*
// 
// Возвращаемое значение:
// 	Структура - Соответствие типов и расширений
&НаСервере
Функция СоответствиеТиповМакетов()
	Соответствие = Новый Структура;

	Соответствие.Вставить("BinaryData", "bin");
	Соответствие.Вставить("SpreadsheetDocument", "mxlx");
	Соответствие.Вставить("DataCompositionSchema", "dcs");
	Соответствие.Вставить("FileAwareTextDocument", "txt");
	Соответствие.Вставить("HtmlDocument", "htmldoc");
	Соответствие.Вставить("AddIn", "addin");
	Соответствие.Вставить("GraphicalScheme", "scheme");
	Соответствие.Вставить("GraphicalSchema", "scheme");
	Соответствие.Вставить("ActiveDocument", "axdt");
	Соответствие.Вставить("GeographicalSchema", "geos");
	Соответствие.Вставить("DataCompositionAppearanceTemplate", "dcsat");

	Возврат Соответствие;
КонецФункции

&НаСервере
Функция ПрочитатьТипМакета(ИмяФайлаМакета)
	
	Файл = Новый Файл(ИмяФайлаМакета);
	Если НЕ Файл.Существует() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ТипМакета = Неопределено;
	
	ЧтениеXML = Новый ЧтениеXML();
	ЧтениеXML.ОткрытьФайл(ИмяФайлаМакета);
	
	Пока ЧтениеXML.Прочитать() Цикл

		Если ЧтениеXML.Имя = "TemplateType" Тогда
			ЧтениеXML.Прочитать();
			Если ЧтениеXML.ИмеетЗначение Тогда
				ТипМакета = ЧтениеXML.Значение;
			КонецЕсли;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	ЧтениеXML.Закрыть();
	
	Возврат  ТипМакета;
	
КонецФункции

&НаСервереБезКонтекста
Процедура ПрочитатьТекстовыйФайлНаСервере(ПутьКФайлу, Текст, ИмяФайла, КодировкаСистемы = Ложь)
	
	ОбщегоНазначения.ПрочитатьТекстовыйФайл(ПутьКФайлу, Текст, ИмяФайла, КодировкаСистемы);
	
КонецПроцедуры

#КонецОбласти
