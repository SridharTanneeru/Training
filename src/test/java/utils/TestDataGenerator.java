package utils;

import java.time.*;
import java.util.Date;
import java.text.SimpleDateFormat;


public class TestDataGenerator
{
    private static final String defaultLocale = "en-GB";
    public static long number()
    {
        int offset = (int) (Math.random() * 1000) + 1;
        return System.currentTimeMillis() + offset;
    }

    // public static String uuid()
    // {
    //     return UUID.randomUUID().toString();
    // }

    public static String uniqueID()
    {
        String str = "yyMMddhhmmss";
        Date now = new Date();
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(str);
        return simpleDateFormat.format(now);
    }

    public static ZonedDateTime currentTimeInLocalZone()
    {
        Date now = new Date();
        return ZonedDateTime.now(ZoneId.of("Australia/Melbourne"));
    }

    public static String TimeInFutureByMinutes(int minutes)
    {
        String currentTime = currentTimeInLocalZone().plusMinutes(minutes).toString();
        return currentTime.substring(0, 19);
    }

    public static String TimeInFutureByHours(int hours)
    {
        String currentTime = currentTimeInLocalZone().plusHours(hours).toString();
        return currentTime.substring(0, 19);
    }

    public static String TimeInFutureByDays(int days)
    {
        String currentTime = currentTimeInLocalZone().plusDays(days).toString();
        return currentTime.substring(0, 19);
    }

    public static String TimeInThePastByDays(int days)
    {
        String currentTime = currentTimeInLocalZone().minusDays(days).toString();
        return currentTime.substring(0, 19);
    }

    public static String TimeInThePastByHours(int hours)
    {
        String currentTime = currentTimeInLocalZone().minusHours(hours).toString();
        return currentTime.substring(0, 19);
    }

    public static String TimeInThePastByMinutes(int minutes)
    {
        String currentTime = currentTimeInLocalZone().minusMinutes(minutes).toString();
        return currentTime.substring(0, 19);
    }
}