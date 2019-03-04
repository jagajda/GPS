#ifndef WEATHERDATASTRUCT_H
#define WEATHERDATASTRUCT_H
#include <cstdint>
#include <QString>
typedef struct WeatherDataStruct{

    //cordinates
    int16_t lon;    //logtitude
    int16_t lat;    //latitude

    //weather
    uint8_t id; //Weather condition id
    QString main;   //group of weather parameters (Rain, Snow, Extreme etc.)
    QString description;    //Weather condition within the group
    QString icon;   //icon- if needed

    //QString  base;

    //main
    int8_t temp;
    uint8_t pressure;
    uint8_t humidity;
    int8_t temp_min;    //minimum temperature at the moment
    int8_t temp_max;    // maximum temperature at the moment

    int8_t visibility;  //visibility, meter

    //wind
    uint8_t speed;
    uint8_t deg;

    //clouds
    uint8_t all;    //cloudiness

    //dt
    uint16_t dt;    //time of data calculation, unix, UTC 

    //sys
    QString country;    //country code (GB, PL etc.)
    QString name;       //city name 
}Weather;

#endif // WEATHERDATASTRUCT_H
