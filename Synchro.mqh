//+------------------------------------------------------------------+
//|                                                   ObjectData.mqh |
//|                                                      nicholishen |
//|                                   www.reddit.com/u/nicholishenFX |
//+------------------------------------------------------------------+
#property strict
#include <ChartObjects\ChartObject.mqh>
#include <Controls\BmpButton.mqh>
#include <Controls\Button.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayLong.mqh>
#include <WinUser32.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCopyObject : public CChartObject
{
protected:
   long           m_my_id;
   ENUM_OBJECT    m_type;
   CCopyObject   *m_other;
public:
                  CCopyObject(long other_ch,string name);
                  CCopyObject(long other_ch,string name,int type,int sub_window);
                 ~CCopyObject();
   bool           Copy(CCopyObject* other);
   bool           Create();
   bool           Compare();
   int            Type() const {return m_type;}
   int            NumPoints();
protected:
   ENUM_OBJECT    ObjType(long ch,string name)const { return (ENUM_OBJECT)::ObjectGetInteger(ch,name,OBJPROP_TYPE);}
   int            SW()      const   { return ::ObjectFind(m_chart_id,m_name);}
   bool           CrT1();
   bool           CrP1();
   bool           CrT1P1();
   bool           CrT2P2();
   bool           CrT3P3();
 
   void           CopyAttributes(); 
};
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
CCopyObject::CCopyObject(long other_ch,string name):m_my_id(::ChartID())
{
   m_chart_id  =other_ch;
   m_name      =name;
   m_type      =ObjType(other_ch,name);
   m_window    =SW();
   m_num_points=NumPoints();
   double price = Price(0);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
CCopyObject::CCopyObject(long other_ch,string name,int type,int sub_window):m_my_id(::ChartID())
{
   m_chart_id  =other_ch;
   m_name      =name;
   m_type      =(ENUM_OBJECT)type;
   m_window    =sub_window;
   m_num_points=NumPoints();
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
CCopyObject::~CCopyObject()
{
   Detach();
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool CCopyObject::Copy(CCopyObject *other)
{
   m_other = other;
   if(::ObjectFind(m_my_id,Name())<0)
      if(!Create())
         ::Print(__FUNCTION__+" Failed to create chart study");

   if(!Compare())
      CopyAttributes();
   return true;
}
//+------------------------------------------------------------------+
bool CCopyObject::CrP1(void)
{
   return ::ObjectCreate(m_name,m_type,m_window,0,Price(0));
}
//+------------------------------------------------------------------+
bool CCopyObject::CrT1(void)
{
   return ::ObjectCreate(m_name,m_type,m_window,Time(0),0);
}
//+------------------------------------------------------------------+
bool CCopyObject::CrT1P1(void)
{
   return ::ObjectCreate(m_name,m_type,m_window,Time(0),Price(0));
}
//+------------------------------------------------------------------+
bool CCopyObject::CrT2P2(void)
{
   return ::ObjectCreate(m_name,m_type,m_window,Time(0),Price(0),Time(1),Price(1));
}
//+------------------------------------------------------------------+
bool CCopyObject::CrT3P3(void)
{
   return ::ObjectCreate(m_name,m_type,m_window,Time(0),Price(0),Time(1),Price(1),Time(2),Price(2));
}
//+------------------------------------------------------------------+
void CCopyObject::CopyAttributes(void)
{
   for(int i=0;i<3;i++)
   {
      if(Price(i) > 0)
         m_other.Price(i,Price(i));
      if(Time(i) > 0)
         m_other.Time(i,Time(i));
   }
   m_other.Color(this.Color());
   m_other.Style(this.Style());
   m_other.Width(this.Width());
   m_other.Background(this.Background());
   m_other.Fill(this.Fill());
   m_other.Z_Order(this.Z_Order());
   m_other.Selectable(this.Selectable());
   m_other.Selected(this.Selected());
   m_other.Hidden(this.Hidden());
   m_other.Description(this.Description());
   m_other.LevelsCount(this.LevelsCount());
   for(int i=0;i<this.LevelsCount();i++)
   {
      m_other.LevelValue(i,this.LevelValue(i));
      m_other.LevelDescription(i,this.LevelDescription(i));
      m_other.LevelColor(i,this.LevelColor(i));
      m_other.LevelStyle(i,this.LevelStyle(i));
      m_other.LevelWidth(i,this.LevelWidth(i));  
   } 
}
//+------------------------------------------------------------------+
bool  CCopyObject::Compare()
{
   /// might need to find chart object first ??
   for(int i=0;i<4;i++)
      if(this.Price(i) != m_other.Price(i) || this.Time(i) != m_other.Time(i))
         return false;
   if(this.Color()      != m_other.Color())
      return false;
   if(this.Style()      != m_other.Style())
      return false;
   if(this.Width()      != m_other.Width() )
      return false;
   if(this.Background() != m_other.Background() )
      return false;
   if(this.Fill()       != m_other.Fill())
      return false;
   //if(this.Z_Order()    != m_other.Z_Order())
   //   return false;
   if(this.Selectable() != m_other.Selectable())
      return false;
   //if(this.Selected()   != m_other.Selected())
   //   return false;
   if(this.Hidden()     != m_other.Hidden())
      return false;
   if(this.Description()!= m_other.Description())
      return false;
   //if(this.Tooltip()    != m_other.Tooltip())
   //   return false;
   if(this.LevelsCount()!= m_other.LevelsCount())
      return false;
   return true;
}
//+------------------------------------------------------------------+   
bool CCopyObject::Create(void)
{
   switch(m_type)
   {
      case OBJ_VLINE          :  return CrT1();     
      case OBJ_HLINE          :  return CrP1();     
      case OBJ_TREND          :  return CrT2P2();
      case OBJ_TRENDBYANGLE   :  return CrT2P2(); 
      case OBJ_CYCLES         :  return CrT2P2(); 
      case OBJ_CHANNEL        :  return CrT3P3();
      case OBJ_STDDEVCHANNEL  :  return CrT2P2(); 
      case OBJ_REGRESSION     :  return CrT2P2(); 
      case OBJ_PITCHFORK      :  return CrT3P3();
      case OBJ_GANNLINE       :  return CrT2P2();
      case OBJ_GANNFAN        :  return CrT2P2();
      case OBJ_GANNGRID       :  return CrT2P2();
      case OBJ_FIBO           :  return CrT2P2();
      case OBJ_FIBOTIMES      :  return CrT2P2();
      case OBJ_FIBOFAN        :  return CrT2P2();
      case OBJ_FIBOARC        :  return CrT2P2();
      case OBJ_FIBOCHANNEL    :  return CrT3P3();
      case OBJ_EXPANSION      :  return CrT3P3();
      case OBJ_RECTANGLE      :  return CrT2P2();
      case OBJ_TRIANGLE       :  return CrT3P3();
      case OBJ_ELLIPSE        :  return CrT2P2();
      case OBJ_ARROW          :  return CrT1P1();
   }
   return false; 
}
//+------------------------------------------------------------------+
int CCopyObject::NumPoints(void)
{
   switch(m_type)
   {
      case OBJ_VLINE          :  return 1;     
      case OBJ_HLINE          :  return 1;    
      case OBJ_TREND          :  return 2;
      case OBJ_TRENDBYANGLE   :  return 2; 
      case OBJ_CYCLES         :  return 2; 
      case OBJ_CHANNEL        :  return 3;
      case OBJ_STDDEVCHANNEL  :  return 2; 
      case OBJ_REGRESSION     :  return 2;
      case OBJ_PITCHFORK      :  return 3;
      case OBJ_GANNLINE       :  return 2;
      case OBJ_GANNFAN        :  return 2;
      case OBJ_GANNGRID       :  return 2;
      case OBJ_FIBO           :  return 2;
      case OBJ_FIBOTIMES      :  return 2;
      case OBJ_FIBOFAN        :  return 2;
      case OBJ_FIBOARC        :  return 2;
      case OBJ_FIBOCHANNEL    :  return 3;
      case OBJ_EXPANSION      :  return 3;
      case OBJ_RECTANGLE      :  return 2;
      case OBJ_TRIANGLE       :  return 3;
      case OBJ_ELLIPSE        :  return 2;
      case OBJ_ARROW          :  return 1;
   }
   return -1; 
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Synchro : public CArrayObj
{
protected:
   long           m_id;
public:
                  Synchro();//:m_id(::ChartID()){} 
                 ~Synchro();
   CCopyObject*   operator[](const int index)const{return(CCopyObject*)At(index);}
   bool           Sync(long ch,string name);
   int            Index(string name);
protected:
   void           ObjectDelete(long ch,string name);
};
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
Synchro::Synchro():m_id(::ChartID())
{

} 
Synchro::~Synchro()
{

}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool Synchro::Sync(long ch,string name)
{
   bool found = false;
   for(int i=Total()-1;i >=0;i--)
   {
      found = false;
      for(int j=0;j<ObjectsTotal(ch);j++)
      {
         if(this[i].Name() == ObjectName(ch,j))
         {
            found = true;
            break;
         }
      }
      if(!found)
      {
         ObjectDelete(m_id,this[i].Name());
         Delete(i);  
         continue;    
      }
   }
   CCopyObject orig(ch,name);
   if(orig.NumPoints() < 0)
      return true;
   CCopyObject *my;
   int index = Index(name);
   if(index<0)
   {
      my = new CCopyObject(m_id,orig.Name(),orig.Type(),orig.Window());
      Add(my);
   }
   else
      my = this[index];
   if(orig.ChartId()==m_id)
         return true;
   orig.Copy(my);
   return true;
}
//+------------------------------------------------------------------+
int Synchro::Index(string name)
{
   bool  found_already = false;
   for(int i=Total()-1;i>=0;i--)
      if(this[i].Name() == name)
         return i; 
   return -1;
}
//+------------------------------------------------------------------+
void Synchro::ObjectDelete(long ch,string name)
{
   ENUM_OBJECT study[]={OBJ_VLINE,        OBJ_HLINE,        OBJ_TREND,        
                        OBJ_CYCLES,       OBJ_CHANNEL,      OBJ_STDDEVCHANNEL,
                        OBJ_PITCHFORK,    OBJ_GANNLINE,     OBJ_GANNFAN,     
                        OBJ_FIBO,         OBJ_FIBOTIMES,    OBJ_FIBOFAN,      
                        OBJ_FIBOCHANNEL,  OBJ_EXPANSION,    OBJ_RECTANGLE,
                        OBJ_TRIANGLE,     OBJ_ELLIPSE,      OBJ_ARROW,
                        OBJ_TRENDBYANGLE, OBJ_REGRESSION,   OBJ_GANNGRID,  
                        OBJ_FIBOARC,
                        };
   for(int i=0;i<ArraySize(study);i++)
   {
      ENUM_OBJECT type = (ENUM_OBJECT)ObjectGetInteger(ch,name,OBJPROP_TYPE);
      if(type == study[i])
      { 
         ::ObjectDelete(ch,name);
         return;
      }   
   }
}
//+------------------------------------------------------------------+