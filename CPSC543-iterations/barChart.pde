import org.gicentre.utils.stat.*;

private PVector dataPoint;
private int barIndex;

private float barHeight;
private float[] barValues = {0.76, 0.24, 0.39, 0.18, 0.20}; // barchart values

BarChart barChart;
 
void setup()
{
  size(600,600);
  
  barChart = new BarChart(this);
  barChart.setData(barValues);
  
  barChart.setMinValue(0);
  barChart.setMaxValue(1);
  
  barChart.showValueAxis(true);
  barChart.showCategoryAxis(true);  
}
 
void draw()
{
  background(255, 255, 255);
  barChart.draw(15, 15, width - 30, height - 30);
  
  dataPoint = barChart.getScreenToData(new PVector(mouseX, mouseY));
  if (dataPoint != null)
  {
    barIndex = (int)dataPoint.x;
    if (barValues[barIndex] != barHeight)
      println(barHeight = barValues[barIndex]);
  }
}
