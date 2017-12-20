//+------------------------------------------------------------------+
//|                                                  CopyObjects.mqh |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
// TODO next test is to use the master chart to just write objects to other charts.

#property copyright "nicholishen"
#property link      "www.reddit.com/u/nicholishenFX"
#property version   "1.00"
#property strict
#include "Synchro.mqh"
#resource "\\Images\\multi1.bmp"
#resource "\\Images\\multi2.bmp"
#resource "\\Images\\icon_on.bmp"
#resource "\\Images\\icon_off.bmp"
enum ANCHOR
{
   RIGHT_UPPER,//Upper righthand corner
   RIGHT_LOWER,//Lower righthand corner
   LEFT_UPPER,//Upper lefthand corner
   LEFT_LOWER//Lower lefthand corner
};

enum DEFAULTS
{
   ON,//Sync ON by default
   OFF,//Sync OFF by default
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CChartObjectSync : public CObject
{
protected:
   Synchro           m_syn;
   const string      m_symbol;
   //const string      m_ind_name;
   const long        m_id;
   const int         m_hash_id;
   const string      m_global;
   const string      m_Bglobal;
   CBmpButton        m_button;
   CBmpButton        m_button2;
   ANCHOR            m_anchor;
   string            m_sync_button;
   string            m_multi_button;
   string            m_template;
   //CArrayLong        m_opened;
public:
                     CChartObjectSync();
                    ~CChartObjectSync();
   void              Init(DEFAULTS,ANCHOR);
   void              Sync();
   void              OnChartEvent(int id,string name);
   int               ChartID()      const { return m_hash_id; }
   int               Timer()        const;
   void              Debug(bool d)        { if(d)::Comment(m_id);else ::Comment("");}
   void              OpenCharts();
   void              CloseCharts();
protected:
   bool              TakeControl()  const {  ::EventSetTimer(1);
                                             //::ChartSetInteger(m_id,CHART_BRING_TO_TOP,true);
                                             return (GVS() != datetime(0));}
   bool              HasControl()   const { return (GVG() == m_hash_id);  }                        
   int               Hash(long id);
   long              ActiveChartID();
   void              ButtonMove(); 
   
   int               GVG()          const { return  (int)::GlobalVariableGet  (m_global);}
   bool              GVC()          const { return       ::GlobalVariableCheck(m_global);}
   bool              GVD()          const { return       ::GlobalVariableDel  (m_global);}
   datetime          GVS()          const { return       ::GlobalVariableSet  (m_global,(double)m_hash_id);}
   
   bool              BGVG()         const { return (bool)::GlobalVariableGet  (m_Bglobal);}
   bool              BGVC()         const { return       ::GlobalVariableCheck(m_Bglobal);}
   bool              BGVD()         const { return       ::GlobalVariableDel  (m_Bglobal);}
   datetime          BGVS(bool push)const { return       ::GlobalVariableSet  (m_Bglobal,(double)push);}
};

CChartObjectSync::CChartObjectSync():  m_symbol    (::Symbol()),
                                       m_template  (m_symbol+"_Sync"),
                                       m_global    ("__COS__"),
                                       m_Bglobal   ("__BCOS__"),
                                       m_id        (::ChartID()),
                                       m_hash_id   (Hash(m_id)),
                                       m_sync_button("__ROS_button__"+string(m_hash_id)),
                                       m_multi_button("__MULTI_button__"+string(m_hash_id))
{
 //::ChartApplyTemplate(m_id,m_template);
}
//+------------------------------------------------------------------+
CChartObjectSync::~CChartObjectSync()
{
   GVD();
   BGVD();
   m_syn.Clear();
   m_button.Destroy();
   m_button2.Destroy();
 //::ChartSaveTemplate(m_id,m_template);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CChartObjectSync::OnChartEvent(int id,string name)
{
   if(id == CHARTEVENT_CHART_CHANGE)
      ButtonMove();
   if(id == CHARTEVENT_OBJECT_CLICK || id==CHARTEVENT_CLICK || CHARTEVENT_MOUSE_MOVE)
   {
      if(!HasControl())
         TakeControl();
      if(id==CHARTEVENT_OBJECT_CLICK)
         if(name==m_multi_button)//   Print(name);
            if(m_button2.Pressed())
               OpenCharts();
            else
            if(!m_button2.Pressed())
               CloseCharts();
      
   }
   if(id == CHARTEVENT_OBJECT_CREATE)
   {
      TakeControl();
      m_syn.Sync(m_id,name);   
   }
}

void CChartObjectSync::ButtonMove()
{
   int x = (int)::ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int y = (int)::ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   switch(m_anchor)
   {
      case RIGHT_LOWER: 
         m_button.Move(x-27,y-27);  
         m_button2.Move(x-26-27,y-27);
         break;
      case RIGHT_UPPER: 
         m_button.Move(x-27,2);  
         m_button2.Move(x-26-27,2);   
         break;
      case LEFT_LOWER:  
         m_button.Move(1,y-27);    
         m_button2.Move(27,y-27); 
         break;
      case LEFT_UPPER:  
         m_button.Move(1,1); 
         m_button2.Move(27,1);         
         break;
   }
}
//+------------------------------------------------------------------+
void CChartObjectSync::Init(DEFAULTS def = ON,ANCHOR anchor = RIGHT_LOWER)
{
   //for(int i=0;i<::ObjectsTotal(ch);i++)
   //{
   //   if(StringFind(ObjectName(ch,i),"__ROS")>=0 || StringFind(ObjectName(ch,i),"__MULTI")>=0)
   //   {
   //      ObjectDelete(ch,ObjectName(ch,i));
   //   }
   //}     
   ObjectsDeleteAll(m_id,"__");
   for(int i=0;i<::ObjectsTotal(m_id);i++)
      m_syn.Sync(m_id,ObjectName(m_id,i));//FilterAdd(m_id,::ObjectName(0,i));
   Sync();
   TakeControl();
   ::Print(__FUNCTION__+": Initialized on "+Symbol()+" = "+string(m_hash_id)+" | "+string(m_id));
   ::MathSrand(::GetTickCount());
   m_anchor = anchor;
   m_button.Create(m_id,m_sync_button,0,10,10,100,100);
   m_button.BmpNames("::icon_on.bmp","::icon_off.bmp");
   //m_button.Visible(true);
   m_button.Size(25,25);
   m_button2.Create(m_id,m_multi_button,0,10,10,100,100);
   m_button2.BmpNames("::multi1.bmp","::multi2.bmp");
   if(BGVC())
      m_button2.Pressed(BGVG());
   //m_button.Visible(true);
   m_button2.Size(25,25);
   if(def==OFF)
      m_button.Pressed(true);
   ButtonMove();
}
//+------------------------------------------------------------------+
void CChartObjectSync::Sync(void)
{
   if(!BGVC())
      BGVS(m_button2.Pressed());
   else
      m_button2.Pressed(BGVG());
   
   if(!GVC())
      TakeControl();
   if(HasControl())
      return;
   //if(m_button2.Pressed())
   //   OpenCharts();
   // another chart has control
   for(long ch = ::ChartFirst();ch >=0; ch = ::ChartNext(ch) )
   {
      if(::ChartSymbol(ch) == m_symbol && GVG() == Hash(ch)) // we're on a different chart with same symbol'
      {
         for(int i=0;i<::ObjectsTotal(ch);i++)
         {
            if(!m_button.Pressed())   
            { 
               m_syn.Sync(ch,ObjectName(ch,i));
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
int  CChartObjectSync::Timer(void)const
{
   int ms = ::rand()%100;
   return( ms > 10 ? ms : 50);
}
//+------------------------------------------------------------------+
long CChartObjectSync::ActiveChartID(void)
{
   for(long ch = ::ChartFirst();ch >=0; ch = ::ChartNext(ch) )
   {
      if(ChartSymbol(ch) == m_symbol && Hash(ch)==GVG())
         return ch;
   }
   return NULL;
}
//+------------------------------------------------------------------+
int CChartObjectSync::Hash(long key)
{
   char arr[];
   string hash = string(key);
   int total=0;
   ::StringToCharArray(hash,arr);
   for(int i=0;i<::ArraySize(arr);i++)
      total+= int(arr[i]);
   return total;
}

void CChartObjectSync::OpenCharts(void)
{
   BGVS(true);
   ENUM_TIMEFRAMES periods[]={PERIOD_D1,PERIOD_H1,PERIOD_M15,PERIOD_M5};
   ENUM_TIMEFRAMES found_tf[],missing[];
   for(long ch = ::ChartFirst();ch >=0; ch = ::ChartNext(ch) )
   {
      if(ChartSymbol(ch) == m_symbol)
      {
         int index = ArrayResize(found_tf,ArraySize(found_tf)+1) -1;
         found_tf[index] = ChartPeriod(ch);
      }  
   }
   for(int i=0;i<ArraySize(periods);i++)
   {  
      bool found = false;
      for(int j=0;j<ArraySize(found_tf);j++)
      {
         if(periods[i]==found_tf[j])
         {
            found = true;
            break;
         }
      }
      if(!found)
      {
         int index = ArrayResize(missing,ArraySize(missing)+1) -1;
         missing[index] = periods[i];
      }
   }
   for(int i=0;i<ArraySize(missing);i++)
   {
      //m_opened.Add(
      long chart = ChartOpen(m_symbol,missing[i]);
      //uchar name2[];
      //StringToCharArray(m_ind_name,name2,0,StringLen(m_ind_name));
      //int hWnd = WindowHandle(ChartSymbol(chart),ChartPeriod(chart));
      //int MessageNumber=RegisterWindowMessageW("MetaTrader4_Internal_Message");
      //int r=PostMessageW(hWnd,MessageNumber,15,name2);
      //int h=0;
   }
   int wHandle = (int)ChartGetInteger(0,CHART_WINDOW_HANDLE);
   int hMDI    = GetParent(GetParent(wHandle));
   int ret     = SendMessageA(hMDI, WM_MDITILE, 0, 0);
   
   //m_opened.Add(m_id);
   //m_button2.Pressed(false);
}

void CChartObjectSync::CloseCharts(void)
{
   BGVS(false);
   //if(HasControl())
   //   return;
   for(long ch = ::ChartFirst();ch >=0; ch = ::ChartNext(ch) )
   {
      if(::ChartID() != ch && ChartSymbol(ch) == m_symbol)
      {
         for(int i=0;i<::ObjectsTotal(ch);i++)
         {
            if(StringFind(ObjectName(ch,i),"__ROS")>=0 || StringFind(ObjectName(ch,i),"__MULTI")>=0)
            {
               for(int j=0;j<::ObjectsTotal(ch);j++)
               {
                  if(StringFind(ObjectName(ch,j),"__ROS")==0 || StringFind(ObjectName(ch,j),"__MUL")==0 )
                     ObjectDelete(ch,ObjectName(ch,j));
               }
               Print(__FUNCTION__+" Close command on ",ChartID());
               ChartClose(ch);
               break;
            }
         }     
      }
   }
   int hWnd = (int)ChartGetInteger(0, CHART_WINDOW_HANDLE, 0);
   ChartSetInteger(0, CHART_BRING_TO_TOP, true);
   int parent = GetParent(hWnd);
   SendMessageA(GetParent(parent), WM_MDIMAXIMIZE, parent, 0);
}
