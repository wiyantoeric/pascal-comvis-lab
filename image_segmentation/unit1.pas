unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtDlgs, StdCtrls,
  ExtCtrls, Buttons, ComCtrls, TAGraph, TAIntervalSources, TAChartImageList;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ButtonErosi: TButton;
    ButtonDilasi: TButton;
    ButtonTepi: TButton;
    ButtonSegmen: TButton;
    ButtonLoad: TButton;
    ButtonSave: TButton;
    Image1: TImage;
    Image10: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    Segmentasi: TStaticText;
    TrackBar1: TTrackBar;
    procedure Button1Click(Sender: TObject);
    procedure ButtonErosiClick(Sender: TObject);
    procedure ButtonDilasiClick(Sender: TObject);
    procedure ButtonTepiClick(Sender: TObject);
    procedure ButtonSegmenClick(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure Image9Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);

    procedure Dilasi();
    procedure Erosi();
    procedure printBiner();
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
uses
  windows;

var
  bitmapR, bitmapG, bitmapB, bitmapGray, bitmapGrayFilter, bitmapRedFilter, bitmapGreenFilter, bitmapBlueFilter, bitmapBiner, bitmapBinerMorph : array[-1..1000,-1..1000] of integer;
  TepiAtas, TepiBawah, TepiKiri, TepiKanan : integer;
  isMorphed : boolean = false;

procedure TForm1.ButtonLoadClick(Sender: TObject);
var
  j, i, ki, kj, r, g, b, gray, kRed, kGreen, kBlue : integer;
  smoothingFilter : array[0..2,0..2] of single = ((1/9,1/9,1/9),(1/9,1/9,1/9),(1/9,1/9,1/9));
begin
  if (OpenPictureDialog1.Execute) then
  begin
    Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
  end;                              

  image2.Width :=image1.width;
  image2.height:=image1.height;

  image3.Width :=image1.width;
  image3.height:=image1.height;

  image4.Width :=image1.width;
  image4.height:=image1.height;

  image5.Width :=image1.width;
  image5.height:=image1.height;

  image9.width := image1.width;
  image9.height := image1.height;

  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      //mengambil nilai RGB
      R := GetRValue(image1.Canvas.Pixels[i,j]);
      G := GetGValue(image1.Canvas.Pixels[i,j]);
      B := GetBValue(image1.Canvas.Pixels[i,j]);

      gray := (R + G + B) div 3;
      bitmapR[i,j] := R;
      bitmapG[i,j] := G;
      bitmapB[i,j] := B;
      bitmapGray[i,j] := gray;

      // mengisi tepi image
      if (i = 0) or (j = 0) or (i = image1.width-1) or (j = image1.height-1) then
      begin
        if i = 0 then
        begin
          bitmapR[i-1,j] := bitmapR[i,j];
          bitmapG[i-1,j] := bitmapG[i,j];
          bitmapB[i-1,j] := bitmapB[i,j];
          bitmapGray[i-1,j] := bitmapGray[i,j];
        end;
        if j = 0 then
        begin
          bitmapR[i,j-1] := bitmapR[i,j];
          bitmapG[i,j-1] := bitmapG[i,j];
          bitmapB[i,j-1] := bitmapB[i,j];
          bitmapGray[i,j-1] := bitmapGray[i,j];
        end;
        if i = image1.width-1 then
        begin
          bitmapR[i+1,j] := bitmapR[i,j];
          bitmapG[i+1,j] := bitmapG[i,j];
          bitmapB[i+1,j] := bitmapB[i,j];
          bitmapGray[i+1,j] := bitmapGray[i,j];
        end;
        if j = image1.height-1 then
        begin
          bitmapR[i,j+1] := bitmapR[i,j];
          bitmapG[i,j+1] := bitmapG[i,j];
          bitmapB[i,j+1] := bitmapB[i,j];
          bitmapGray[i,j+1] := bitmapGray[i,j];
        end;
      end;

      image1.canvas.pixels[i,j] := RGB(bitmapR[i,j],bitmapG[i,j],bitmapB[i,j]);
    end;
  end;

  // blur  
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      kRed := 0;
      kGreen := 0;
      kBlue := 0;

      // filtering
      for ki:=0 to 2 do
      begin
        for kj:=0 to 2 do
        begin
          kRed := round(kRed + bitmapR[i+ki-1,j+kj-1] * smoothingFilter[ki,kj]);
          kGreen := round(kGreen + bitmapG[i+ki-1,j+kj-1] * smoothingFilter[ki,kj]);
          kBlue := round(kBlue + bitmapB[i+ki-1,j+kj-1] * smoothingFilter[ki,kj]);
        end;
      end;

      bitmapRedFilter[i,j] := kRed;
      bitmapGreenFilter[i,j] := kGreen;
      bitmapBlueFilter[i,j] := kBlue;
      image2.canvas.pixels[i,j] := RGB(kRed, kGreen, kBlue);
    end;
  end;

  // grayscale
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      bitmapGrayFilter[i,j] := (bitmapRedFilter[i,j] + bitmapGreenFilter[i,j] + bitmapBlueFilter[i,j]) div 3;
      image3.canvas.pixels[i,j] := RGB(bitmapGrayFilter[i,j],bitmapGrayFilter[i,j],bitmapGrayFilter[i,j]);
    end;
  end;

  // output biner
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      if bitmapGrayFilter[i,j] > 127 then
      begin
        bitmapBiner[i,j] := 1;
      end
      else
      begin
        bitmapBiner[i,j] := 0;
      end;
      image4.canvas.pixels[i,j] := RGB(bitmapBiner[i,j]*255, bitmapBiner[i,j]*255, bitmapBiner[i,j]*255);
    end;
  end;
                                                                                        
      image4.canvas.pixels[10,0] := RGB(0,0,0);
  //for j:=0 to image1.Height-1 do
  //begin
  //  for i:=0 to image1.Width-1 do
  //  begin
  //    image5.canvas.pixels[i,j] := RGB(255,255,255);
  //  end;
  //end;
  //Tform1.btnSegmenClick(nil);

//  72 threshold
  image8.width := image1.width;
  image8.height := image1.height;
  for i:=0 to image1.Width-1 do
  begin
    for j:=0 to image1.Height-1 do
    begin
      if bitmapGrayFilter[i,j] > 72 then image8.canvas.pixels[i,j] := RGB(255,255,255) else image8.canvas.pixels[i,j] := RGB(0,0,0);
    end;
  end;
end;

procedure TForm1.ButtonSegmenClick(Sender: TObject);
var
  i, j : integer;
label
  labelatas, labelkanan, labelbawah, labelprint;
begin
//  tepi kiri
    for i:=0 to image1.Width-1 do
    begin                          
      for j:=0 to image1.Height-1 do
      begin
        if (bitmapBiner[i,j] = 0) then
        begin
          tepikiri := i;
          goto labelatas;
        end;
      end;
    end;

//    tepi atas
    labelatas:
    for i:=0 to image1.width-1 do
    begin
      for j:=0 to image1.height-1 do
      begin
        if (bitmapBiner[j,i] = 0) then
        begin
          tepiatas := i;
          goto labelkanan;
        end;
      end;
    end;

//    tepi kanan
    labelkanan:
    i:=image1.width-1;
    while i >= 0 do
    begin
      for j:=0 to image1.Height-1 do
      begin
        if (bitmapBiner[i,j] = 0) then
        begin
          tepikanan := i;
          goto labelbawah;
        end;
      end;
      i := i-1;
    end;
                  
    //  tepi bawah
    labelbawah:
    i:=image1.width-1;
    while i >= 0 do
    begin
      j:=image1.height-1;
      while j >= 0 do
      begin
        if (bitmapBiner[j,i] = 0) then
        begin
          tepibawah := i;
          goto labelprint;
        end;
        j := j-1;
      end;
      i := i-1;
    end;

  labelprint:
  for i:=tepikiri to tepikanan do
  begin
    for j:=tepiatas to tepibawah do
    begin
      image5.canvas.pixels[i,j] := RGB(bitmapBiner[i,j]*255, bitmapBiner[i,j]*255, bitmapBiner[i,j]*255);
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  i, j, mostColor, darkest, mostDark, darkIndex : integer;
  grayHistogram : array[0..1000] of integer;

begin
  mostColor := 0;
  darkest := 255;
  mostDark := 255;

  for i:=0 to 255 do
  begin
    grayHistogram[i] := 0;
  end;

  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      grayHistogram[bitmapGray[i,j]] := grayHistogram[bitmapGray[i,j]] + 1;
      if bitmapGray[i,j] < darkest then darkest := bitmapGray[i,j];
    end;
  end;
                                  
  for i:=0 to 255 do
  begin
    if grayHistogram[i] > mostColor then mostColor := grayHistogram[i];
  end;

  for i:=0 to 127 do
  begin
    if grayHistogram[i] > mostDark then
    begin
      mostDark := grayHistogram[i];
      darkIndex := i;
    end;
  end;

  label5.caption := inttostr(mostColor);
  label6.caption := inttostr(darkIndex);
  label7.caption := inttostr(mostDark);

  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      if (bitmapGray[i,j] < darkest + 80) then
      begin
        image6.canvas.pixels[i,j] := RGB(bitmapGray[i,j],bitmapGray[i,j],bitmapGray[i,j]);
      end
      else
      begin
        image6.canvas.pixels[i,j] := RGB(255,255,255);
      end;
    end;
  end;
end;

procedure TForm1.ButtonErosiClick(Sender: TObject);
begin
  Erosi();  
  printBiner();
end;

procedure TForm1.ButtonDilasiClick(Sender: TObject);
begin
  Dilasi();
end;

procedure TForm1.ButtonTepiClick(Sender: TObject);
var
  i, j, ki, kj : integer;
  bitmapTepi : array[0..1000, 0..1000] of integer;
  kernelTepi : array[0..2, 0..2] of integer = ((1,1,1),(1,-8,1),(1,1,1));
begin
  image8.height := image1.height;
  image8.width := image1.width;

  for i:=0 to image8.width do
  begin
    for j:=0 to image8.height do
    begin
    bitmapTepi[i,j] := 0;

    for ki:=0 to 2 do
      begin
        for kj:=0 to 2 do
        begin
          bitmapTepi[i,j] := round(bitmapTepi[i,j] + bitmapBiner[i+ki-1,j+kj-1] * kernelTepi[ki,kj]);
        end;
      end;
    if bitmapTepi[i,j] < 0 then bitmapTepi[i,j] := 0;
    if bitmapTepi[i,j] > 1 then bitmapTepi[i,j] := 1;

    image8.canvas.pixels[i,j] := RGB(bitmapTepi[i,j]*255,bitmapTepi[i,j]*255,bitmapTepi[i,j]*255);
    end;
  end;
end;

procedure TForm1.ButtonSaveClick(Sender: TObject);
begin
  if (SavePictureDialog1.Execute) then
  begin
    image4.Picture.SaveToFile(SavePictureDialog1.FileName);
  end;
end;

procedure TForm1.Image9Click(Sender: TObject);
begin

end;

procedure TForm1.TrackBar1Change(Sender: TObject);
var
  i, j, threshold : integer;
begin
  threshold := trackbar1.position;
  label8.caption := inttostr(threshold);
  image7.width := image1.width;
  image7.height := image1.height;
  for i := 0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      if bitmapGrayFilter[i,j] > threshold then image7.canvas.pixels[i,j] := RGB(255,255,255) else image7.canvas.pixels[i,j] := RGB(0,0,0);
    end;
  end;
end;

procedure TForm1.Dilasi();
var
  i, j, kj, ki : integer;
  SE : array[-1..1,-1..1] of integer = ((0,0,0),(0,0,0),(0,0,0));
  bitmapBin : array [0..1000,0..1000] of integer;
  temp : boolean;
begin
  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      temp := false;
      for kj:= -1 to 1 do
      begin
        for ki:= -1 to 1 do
        begin
          if isMorphed then
            temp := temp OR (bitmapBinerMorph[i+ki,j+kj] = SE[ki,kj])
          else
            temp := temp OR (bitmapBiner[i+ki,j+kj] = SE[ki,kj]);
        end;
      end;

      if temp then
      begin
        bitmapBinerMorph[i,j] := 0;
        bitmapBin[i,j] := 0;
      end
      else
      begin
        bitmapBinerMorph[i,j] := 1;
        bitmapBin[i,j] := 1;
      end;
    end;
  end;

//  printing
  //printBiner();

    //else
  //begin                       
  //  isMorphed := true;
  //  for i:=0 to image9.width-1 do
  //  begin
  //    for j:=0 to image9.height-1 do
  //    begin
  //      bitmapBinerMorph[i,j] := bitmapBiner[i,j];
  //      image9.canvas.pixels[i,j] := RGB(bitmapBiner[i,j]*255,bitmapBiner[i,j]*255,bitmapBiner[i,j]*255);
  //    end;
  //  end;
  //end;

  Image9.Canvas.Brush.Color := CLWhite;
  Image9.Canvas.FillRect(0, 0, Image1.Canvas.Width, Image9.Canvas.Height);
  Image9.Canvas.FillRect(0, 0, Image1.Canvas.Width, Image9.Canvas.Height);

  for i:=0 to image9.Width-1 do
  begin
    for j:=0 to image9.Height-1 do
    begin
      image9.canvas.pixels[i,j] := RGB(bitmapBin[i,j]*255,bitmapBin[i,j]*255,bitmapBin[i,j]*255);
    end;
  end;
  isMorphed := true;
end;

procedure TForm1.Erosi();
var
  i, j, kj, ki : integer;
  SE : array[-1..1,-1..1] of integer = ((0,0,0),(0,0,0),(0,0,0));
  temp : boolean;
begin
  for i:=0 to image1.width-1 do
  begin
    for j:=0 to image1.height-1 do
    begin
      temp := false;
      for kj:= -1 to 1 do
      begin
        for ki:= -1 to 1 do
        begin
          temp := temp AND (bitmapBiner[i+ki,j+kj] = SE[ki,kj]);
        end;
      end;

      if temp then
      begin                   
        bitmapBiner[i,j] := 0;
      end
      else
      begin
        bitmapBiner[i,j] := 1;
      end;
                                                                                                         
        image9.canvas.pixels[i,j] := RGB(bitmapBiner[i,j]*255,bitmapBiner[i,j]*255,bitmapBiner[i,j]*255);
    end;
  end;
end;


procedure TForm1.printBiner();
var
  i, j : integer;
begin
  for i:=0 to image9.width-1 do
  begin
    for j:=0 to image9.height-1 do
    begin
      image9.canvas.pixels[i,j] := RGB(bitmapBinerMorph[i,j]*255,bitmapBinerMorph[i,j]*255,bitmapBinerMorph[i,j]*255)
    end;
  end;
end;

end.

