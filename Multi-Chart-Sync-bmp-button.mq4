//+------------------------------------------------------------------+
//|                                          Chart_Object_Sync_1.mq4 |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property description "This indicator synchronizes chart drawing objects with"
#property description "all other charts (same symbol) running this indicator in real-time."
#property description " "
#property description " "
#property description "1C3EzJHNK4kK7nEu1J56vvTnNQJ7ArjHXG (BTC donate)"
#property description " "
#property description "This initial Beta version will expire on 09/01/2017"
#property icon        "Icon.ico"
#property copyright   "nicholishen@FF"
#property link        "http://i.imgur.com/lKcCFvn.png"
#property version     "1.25"
#property strict
#property indicator_chart_window
#include "ChartObjectSync2.mqh"

input DEFAULTS Defaults = ON;          //Sync default to:
input ANCHOR   Location = RIGHT_LOWER; //Button Location
//--- Global Object
CChartObjectSync sync;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   datetime expire = D'2017.09.01';
   if(TimeCurrent() > expire)
      return INIT_FAILED;
   
   if(!IsDllsAllowed()) 
   { 
      MessageBox("Enable DLL imports in settings.",NULL,MB_OK);
      return INIT_FAILED; 
   }    
   
   sync.Init(Defaults,Location);
   EventSetMillisecondTimer(100);
   ChartSetInteger(0,CHART_EVENT_OBJECT_CREATE,true);
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   sync.Debug(false);
   
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   sync.Sync();
   EventSetMillisecondTimer(sync.Timer()); 
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   sync.OnChartEvent(id,sparam);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   return(rates_total);
}

void OnDeinit(const int reason)
{

}
