const weekDays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];

function checkLeapYear(year) {
    return year % 400 === 0 || (year % 4 === 0 && year % 100 !== 0);
}

function getMonthDays(month, year) {
    if ((month <= 7 && month % 2 === 1) || (month >= 8 && month % 2 === 0)) return 31;
    if (month === 2) return checkLeapYear(year) ? 29 : 28;
    return 30;
}

function getNextMonthDays(month, year) {
    if (month === 1) return checkLeapYear(year) ? 29 : 28;
    if (month === 12) return 31;
    return ((month <= 7 && month % 2 === 1) || (month >= 8 && month % 2 === 0)) ? 30 : 31;
}

function getPrevMonthDays(month, year) {
    if (month === 3) return checkLeapYear(year) ? 29 : 28;
    if (month === 1) return 31;
    return ((month <= 7 && month % 2 === 1) || (month >= 8 && month % 2 === 0)) ? 30 : 31;
}

function getDateInXMonthsTime(x, currentDate) {
    if (x === 0) return currentDate;
    const targetMonth = currentDate.getMonth() + x;
    return new Date(currentDate.getFullYear() + Math.floor(targetMonth / 12), (targetMonth % 12 + 12) % 12, 1);
}

function getCalendarLayout(dateObject, highlight) {
    const weekday = (dateObject.getDay() + 6) % 7;
    const day = dateObject.getDate();
    const month = dateObject.getMonth() + 1;
    const year = dateObject.getFullYear();
    const firstDay = (weekday + 35 - (day - 1)) % 7;
    const daysInMonth = getMonthDays(month, year);
    const daysInNextMonth = getNextMonthDays(month, year);
    const daysInPrevMonth = getPrevMonthDays(month, year);
    let monthDiff = firstDay === 0 ? 0 : -1;
    let value = firstDay === 0 ? 1 : daysInPrevMonth - firstDay + 1;
    let limit = firstDay === 0 ? daysInMonth : daysInPrevMonth;
    const calendar = Array.from({ length: 6 }, () => Array(7));

    for (let row = 0; row < 6; row++) {
        for (let col = 0; col < 7; col++) {
            calendar[row][col] = { day: value, today: value === day && monthDiff === 0 && highlight ? 1 : monthDiff === 0 ? 0 : -1 };
            value++;
            if (value > limit) {
                monthDiff++;
                limit = monthDiff === 0 ? daysInMonth : daysInNextMonth;
                value = 1;
            }
        }
    }
    return calendar;
}
