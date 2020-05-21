// Questions :
/*

 Q1 : dessiner joli segment rond pour serpent
 Q2 : dessiner visage serpent (yeux, langue, etc.)
 Q3 : materialiser bordure de scroll (carre)
 Q4 : dessiner joli "noisette" ou "gland" pour nourriture
 Q5 : dessiner un terrain selon perlin
 --------------------------------------
 Note de projet No1 pour le 4 ou 5 decembre
 
 Q6 : dessiner serpent "lumineux" quand "acceleration" avec la touche espace
 Q7 : animation a la mort (mieux que le game-over qui rapetisse)
 Q8 : animation au repas 
 Q9 : dessiner l'ombre d'un quadricoptere au centre du plateau de jeu
 Q10 : tableau des vainqueurs 
 --------------------------------------
 Note de projet No2 pour la soutenance finale debut janvier
*/


// variables globales

PImage img1,img2,img3,img4,img5;
boolean merge = false;
Snake snakes[];
int TerrX     = 40;
int TerrY     = 40;

int gaussR = 11;
float gauss[][];
int panX = 0;
int panY = 0;

int state = 1;

int BORDER_SIZE = 200;
String names[]={"Fred", "Nicolas", "Yacine", "Olivia", "Medhi", "Christian", "Laura"};
int tab1[];


 
ArrayList foods; 
 
// on regroupe les variables d'un serpent dans une structure
class Snake {
  ArrayList pos;
  int size = 16;
  int weight = 160;
  float dirX = 10;
  float dirY = 0;
  float speed = 10;
  float r, g, b;
  String name;
  Snake(String name0,int size0, int x0, int y0, int r0, int g0, int b0, float dirX0, float dirY0){
    r=r0;
    g=g0; 
    b=b0;
    
    name = name0;
    dirX = dirX0;
    dirY = dirY0;
    
    size = size0;
    pos = new ArrayList();
    for (int i = size; i>=0; i--){
      Point s = new Point(x0+i*dirX, y0+i*dirY);
      pos.add(s);
    }
    setWeight(size*10);
  }
  
  void setWeight(int weight1){
    weight = weight1;
    for (int i = size; i>=0; i--){
      Point s = (Point)pos.get(i);
      s.r = 10+sqrt((weight-39))/4.0;
      if (i==1) s.r-=2;
      if (i==2) s.r--;
    }
    
    int acc = 8;
    for (int i = pos.size()-1; i>=3; i--){
      Point s  = (Point)pos.get(i);
      if (acc<s.r)
        s.r = acc;
      acc+=1;
    }
  }
  
}
 
 
// une autre structure pour representer les segments de serpent ou les boules de nourriture 
class Point{
  float x; 
  float y;
  float r;
  Point (float x0, float y0){
    x = x0;
    y = y0;
    r = 15;
  }
}


Point newFood(){
  float a = random(0,10000)*PI/5000;
  float d = random(0,5000);
  
  Point p = new Point(d*cos(a), d*sin(a));
  p.r = random(1,5);
  return p;
}



void setup() {  // this is run once.       
    size(1000,650); 
    
    
    snakes = new Snake[6]; 
    for (int k=1; k<snakes.length; k++){
      snakes[k] = new Snake(names[k], 4+10*(k-1), width/2+(int)(300*cos(k*PI/3)), height/2+(int)(300*sin(k*PI/3)), 128+64*(k%3), 255*(k%2), 0, 10*cos((k+2)*PI/3), 10*sin((k+2)*PI/3));
    }
    
    foods = new ArrayList();
    for (int k=0; k<1000; k++){
      foods.add(newFood());
    }
    
    gauss = new float[gaussR][gaussR];
    for (int k=0; k<gaussR; k++)
      for (int l=0; l<gaussR; l++)
        gauss[k][l] = exp(-1.0/gaussR/gaussR*((k-gaussR/2)*(k-gaussR/2)+(l-gaussR/2)*(l-gaussR/2)));
     
    // 2 images
    img1 = createImage(64, 64, ARGB);
    img2 = createImage(64+gaussR, 64+gaussR, ARGB);
    img3 = createImage(64+gaussR, 64+gaussR, ARGB);
    img4 = createImage(64, 64, ARGB);
    img5 = createImage(64+gaussR, 64+gaussR, ARGB);
    
    
    // Q1 un dessin de cercle dans la premiere image
    for(int j=0; j < img1.height; j++) {
      for(int i=0; i < img1.width; i++) {
        float d0 = dist(i,j,img1.width/2,img1.height/2);
        float d1 = dist(i,j,3*img1.width/4, 3*img1.height/4);
        if (d0<img1.width/2-1){
          
          img1.pixels[i+j*img1.width] = color(185+70*d1/(img1.width/2),250,185+70*d1/(img1.width/2)); 
        }
      }
    }
    
    //q9 crée une image avec un carée
    for(int j=img1.height/4; j < 3*img1.height/4; j++) {
      for(int i=img1.width/4; i < 3*img1.width/4; i++) {
        img4.pixels[i+j*img4.width]=color(0,0,0);
      }
    }  
    // l'ombre du cercle dans la 2ieme image
    for(int j=0; j < img1.height; j++) {
      for(int i=0; i < img1.width; i++) {
        float c = alpha(img1.pixels[i+j*img1.width]);
        float d = alpha(img4.pixels[i+j*img4.width]);
        for (int k=0; k<gaussR; k++){
          for (int l=0; l<gaussR; l++){
            img2.pixels[i+l+(j+k)*img2.width] += c*gauss[k][l]; 
            img3.pixels[i+l+(j+k)*img3.width] += c*gauss[k][l]; 
            img5.pixels[i+l+(j+k)*img3.width] += d*gauss[k][l];
          }
        }
      }
    }
    int ma = img2.pixels[img2.width/2+img2.height/2*img2.width];
    for(int j=0; j < img2.height; j++) {
      for(int i=0; i < img2.width; i++) {
        int value= img2.pixels[i+j*img2.width];
        img2.pixels[i+j*img2.width] = color(0, 128*value/ma);
      }
    }
    // q6 crée une " ombre blanche "
      for(int j=0; j < img3.height; j++) {
      for(int i=0; i < img3.width; i++) {
        int value= img3.pixels[i+j*img3.width];
        img3.pixels[i+j*img3.width] = color(255, 128*value/ma);
      }
    }
    
     for(int j=0; j < img5.height; j++) {
      for(int i=0; i < img5.width; i++) {
        int value= img5.pixels[i+j*img5.width];
        img5.pixels[i+j*img5.width] = color(0, 128*value/ma);
      }
    } 
    
    img1.updatePixels();    
    img2.updatePixels();
    img3.updatePixels();
    img4.updatePixels();
    img5.updatePixels();
    frameRate(25);
} 


void moveSnake(Snake s, float objx, float objy){
  Point p0 = (Point) s.pos.get(0);
  Point pn = (Point) s.pos.get(s.pos.size()-1);
  
  float dd = dist(p0.x, p0.y, objx, objy);
  float tx = objx;
  float ty = objy;
  if (dd>s.speed){
    tx = p0.x+(objx-p0.x)/dd*s.speed;
    ty = p0.y+(objy-p0.y)/dd*s.speed;
  }
  if (dd>0){
    s.dirX = (objx-p0.x)/dd*s.speed;
    s.dirY = (objy-p0.y)/dd*s.speed;
  }
  
  // si on va "vite" on seme de la nourriture derriere soi et on perd du poids
  if(s.speed>10){
    s.setWeight(s.weight -2);
    Point f = new Point(pn.x, pn.y);
    f.r = 1;
    foods.add(f);
      
    if (s.weight<10*s.size){
      s.size--;
      s.pos.remove(s.pos.size()-1);
      
    }
    if (s.weight<42){
      s.speed=10;
    }
  }
  
  // deplace chaque segment du serpent
  float tlen = 0;
  for (int i = 0; i<s.pos.size(); i++){
    Point p = (Point) s.pos.get(i);
    float len = dist(p.x, p.y, tx, ty);
    if (len > tlen){
      p.x = tx-(tx-p.x)*tlen/len;
      p.y = ty-(ty-p.y)*tlen/len;
    }
    tx = p.x;
    ty = p.y;
    tlen = 10; 
  }
}

 
boolean testCollision(Snake s){
  Point p0 = (Point)s.pos.get(0);
  Point pn = (Point)s.pos.get(s.pos.size()-1);
  
  for (int i=0; i<snakes.length; i++){
    Snake other = snakes[i];
    if (other!=null && other!=s){
      for(int k=0; k<other.pos.size(); k++){
        Point p = (Point)other.pos.get(k);
        float dd = dist(p.x, p.y, p0.x, p0.y);
        if (dd<p0.r+p.r){
            return true;


        }
      }
    }
  }
  
  for (int k=foods.size()-1; k>=0; k=k-1){
      
    Point f = (Point)foods.get(k);
    float dd = dist(p0.x, p0.y, f.x, f.y);
    if (dd < p0.r+f.r) {
      s.setWeight(s.weight +(int)f.r);
      

    Point u = (Point) s.pos.get(0);
    
//q8
  
  textSize(14);
  fill(255);
  text(" Miam! ",  u.x+45-panX-1, u.y+20-panY-1);
  
  //dessine emoji
  fill(255,255,0);
  ellipse(u.x+100-panX,u.y+20-panY,20,20);
  fill(0);
  ellipse(u.x+103-panX,u.y+18-panY,3,3);
  ellipse(u.x+97-panX,u.y+18-panY,3,3);
  stroke(255,0,0);
  strokeWeight(0.75);
  bezier(u.x+97-panX,u.y+23-panY,u.x+99-panX,u.y+26-panY,u.x+101-panX,u.y+26-panY,u.x+103-panX,u.y+23-panY);
  noStroke();
  
     
      
      
      if (s.weight>10*s.size){
        s.size++;
        Point p = new Point(pn.x, pn.y);
        p.r= 8;
        s.pos.add(p);
      }
    
      foods.remove(k);
      
    }
  }
  return false;
}

//q10

int indexSerp (Snake snakes[], int poids, ArrayList <String> nom){
  //fonction qui retourne l'index d'un serp ayant un weight = au poids en entrée
int indiceSerp = 0;
int ok = 0;
int i=0;
  for(i=0; (i < snakes.length) ; i++){
    if (snakes[i]!= null){
    if(snakes[i].weight== poids){
          for (int k=0; k < nom.size();k++){
           //chercher si le nom associé à l'indice i est déjà sorti!!
           if(nom.get(k) == snakes[i].name){
             ok=1;
           }
              
          }
          if(ok !=1) {indiceSerp = i;  break;}
          else{ok=0;}
     }
  }
  }
return indiceSerp;
}

  void etoile(int a, int b ,int c , int r1 , int r2){ 
     noStroke();
     fill(255,255,0,40);
     beginShape();
     for (float i=0;i< 2*PI ;i=i+2*PI/5){
        vertex(a+b+r1*cos(i+2*PI/5),c+r1*sin(i+2*PI/5));
        vertex(a+b+r1*cos(i),c+r1*sin(i));
        vertex(a+b+r2*cos(i+PI/5),c+r2*sin(i+PI/5));
 
     }
     endShape(CLOSE);
  }
 
 
void drawSnake(Snake s) {
  for (int i = s.pos.size()-1; i >= 0; i--){
    Point p = (Point) s.pos.get(i);
    pushMatrix();
    translate( p.x-panX, p.y-panY);
    if (i==0){
      rotate(atan2(s.dirY, s.dirX));
      stroke(0);
      strokeWeight(0.8);
      //Q2 dessin dessous
      pushMatrix();
       
      float z=40 +40*sin(millis()/175);
      scale(2.2*p.r/img1.width, 2.0*p.r/img1.width);
      stroke(100,0,0);
      strokeWeight(5);
      line(img1.width/2,0,z,0);
      line(z,0,z+5,-5);
      line(z,0,z+5,+5);
    } else 
      scale(2.0*p.r/img1.width);
   
    if (i%2==0){
      if (s.speed>10){
        //image(img3, 0,0);
        tint(255-s.r/2, 130-s.g/2, 255-s.b/2);
        image(img1, 0,0);
        //q6
        noTint();
        scale(1.25);
        image(img3,0,0);
      }else{
        //image(img2, 0,0);
        
        tint(255-s.r/2, 130-s.g/2, 255-s.b/2);
        image(img1, 0,0);
        noTint();
      }
    } else {
      if (s.speed>10){
        //image(img3, 0,0);
        tint((255-s.r)*255, 200-s.g, (255-s.b)*255);
        image(img1, 0,0);
        //q6
        noTint();
        scale(1.25);
        image(img3,0,0);
      }else{
        //image(img2, 0,0);
        tint((255-s.r)*255, 200-s.g, (255-s.b)*255);
        image(img1, 0,0);
        noTint();
      }

    }
    
    if (i==0){
      popMatrix();
      //Q2 dessin dessus
     
      scale(6*p.r/img1.width);
      strokeWeight(0);
      fill(255);
      ellipse(img1.width/7,img1.height/13,img1.width/8,img1.width/9);
      fill(255);
      ellipse(img1.width/7,-img1.height/13 ,img1.width/8,img1.width/9);
      

      
      fill(0);
      ellipse(img1.width/5.5,img1.height/13,img1.width/15,img1.width/15);
      fill(0);
      ellipse(img1.width/5.5,-img1.height/13,img1.width/15,img1.width/15);
   

    }
    popMatrix();
  }
  
  
  //q10 tableau
  
  //dessine le fond du cadre
  noStroke();
  fill(100,40);
  rect(width-185,40,150,185);


  textSize(14);
  fill(255);
  text ("Top joueurs" ,width-110,60);

  //cree un nouveau tableau avec les size
  int n;
  tab1= new int[snakes.length];
 

  for (int  i=0 ; i < snakes.length ; i++){
    if (snakes[i]!=null ){  
      tab1[i]=snakes[i].weight;
    }
  }
 // ordonne le tableau
   ArrayList <String> nom= new ArrayList<String>();
  tab1=sort(tab1);
  tab1=reverse(tab1);
  
  for (int  i=0 ; i < snakes.length ; i++){
    if (snakes[i]!=null){   
      n=tab1[i];
      text(n  , width-70 ,i*20+100 );  
      int y= indexSerp(snakes, n, nom); // snakes.indexOf(n)    (va chercher le nom correspondant dans le tableau snakes);
      if (snakes [y]!=null){
        nom.add(snakes[y].name );
        text( snakes[y].name  , width-145 ,i*20+100 );
      }
    }
  }
  
  //dessine cadre
     noFill();  
     stroke(255);
     strokeWeight(1.5);
     rect(width-185,40,150,45);
     rect(width-185,40,150,185);
  
  
}
 
// Q5
void drawBg(){
 // background(10,10,30);
 background(20,20,80);
 noStroke();
  
  
  
  for (int j=-panY%20-20; j<=height; j+=20){
    for (int i=-panX%20-20; i<=width; i+=20) {
      
     float n=noise(i+panX,j+panY)*25;
     
     fill(n*4,40,n*8,50);
      
     //fill(10, 10, 180,10);
      ellipse(((((j+panY)/20)%2)*10+i), j, n*2, n*2);
     
     
    
    }
  }
}
 
void draw() {  // this is run repeatedly.  

   
   drawBg();


  textAlign(CENTER, CENTER);
  imageMode(CENTER);
  
  if (state==1){
    fill(0);
    textSize(20);
    text("Appuyer sur une touche pour commencer", width/2, height/2);
    return;
    
  } else if (state>1){
    drawBg();
    //q7 animation tete de mort
    
  background(30);
  stroke(255);
  strokeWeight(8);
  // dessine les os 
  line(width/2-state*6,height/2-state*5,width/2+6*state,height/2+state*5);
  line(width/2-state*6,height/2+state*5,width/2+6*state,height/2-state*5);
  
  fill(255);
  ellipse(width/2-state*7,height/2-state*4.8,state*1.2,state*1.2);
  ellipse(width/2-state*6,height/2-state*5.5,state,state);

  ellipse(width/2-state*7,height/2+state*4.8,state*1.2,state*1.2);
  ellipse(width/2-state*6,height/2+state*5.5,state,state);
  
  ellipse(width/2+state*7,height/2-state*4.8,state*1.2,state*1.2);
  ellipse(width/2+state*6,height/2-state*5.5,state,state);
  
  ellipse(width/2+state*7,height/2+state*4.8,state*1.2,state*1.2);
  ellipse(width/2+state*6,height/2+state*5.5,state,state);
  
  
  
  fill(0);
  noStroke();
  // dessine visage
  ellipse(width/2,height/2,(state*2)*5-(state*2)/10,(state*2)*5);
  rect(width/2-(state*2),height/2,(state*2)*2,(state*2)*3+(state*2)/4);
  fill(255);
  //nez + yeux
  triangle(width/2,height/2+((state*2)/2)+((state*2)/4),width/2+(((state*2)/2)+((state*2)/10))*cos(PI/3),(height/2+(state*2)/2+(state*2)/4)+((state*2)/2+(state*2)/10)*sin(PI/3),width/2+((state*2)/2+(state*2)/10)*cos(-(PI+PI/3)),(height/2+(state*2)/2+(state*2)/4)+((state*2)/2+(state*2)/10)*sin(-(PI+PI/3)));
  ellipse(width/2+(state*2)*cos(-PI/6),(height/2+(state*2)/2)+(state*2)*sin(-PI/6),(state*2)*1.5-(state*2)/20,(state*2)+(state*2)/2);
  ellipse(width/2+(state*2)*cos(-(PI-PI/6)),(height/2+(state*2)/2)+(state*2)*sin(-(PI-PI/6)),(state*2)*1.5-(state*2)/20,(state*2)+(state*2)/2);
  //bouche
  stroke(255);
  strokeWeight(1.5);
  line(width/2-((state*2)+(state*2)/4),height/2+(state*4+(state*2)/1.5),width/2+(state*2)+(2*state)/4,height/2+(state*4)+(state*2)/1.5);
  
  line(width/2-state/5,height/2+state*4+state/2,width/2-state/5,height/2+state*4+state*2);
  line(width/2-((state)+(state/5)),height/2+state*5.8,width/2-((state)+(state/5)),height/2+state*4.8);
  line(width/2+state-state/5,height/2+state*4.6,width/2+state-state/5,height/2+state*5.6);

  noStroke();
    
    
    fill(250,30,30);
    textSize(60);
    
    text("Game OVER", width/2, height/6);
    text("You're DeaD!",width/2, height/4);
    
    
    state--;
    return;
    
  } else {
    moveSnake(snakes[0], mouseX+panX, mouseY+panY);
    // si la position du serpent s'approche du bord, on prefere scoller le jeu plutot que de laisser
    // le serpent s'approcher su bord
    Point p = (Point)snakes[0].pos.get(0);
    if (p.x-panX>width-BORDER_SIZE)
      panX = round(p.x-width+BORDER_SIZE);
    if (p.x-panX<BORDER_SIZE)
      panX = round(p.x-BORDER_SIZE);
    if (p.y-panY>height-BORDER_SIZE)
      panY = round(p.y-height+BORDER_SIZE);
    if (p.y-panY<BORDER_SIZE)
      panY = round(p.y-BORDER_SIZE);  
  }
  
  if (snakes[0]!=null && testCollision(snakes[0])){
     for (int i=0; i<snakes[0].pos.size(); i++){
        Point m = (Point)snakes[0].pos.get(i);
        m.r = 10;
        if (i%2==0) foods.add(m);
      }
      snakes[0] = null;
      state = 20;
  }
    
  

  // deplace les autres serpents de maniere aleatoire
  for (int k=1; k<snakes.length; k++)
    if (snakes[k]!=null){
      float dx = snakes[k].dirX;
      float dy = snakes[k].dirY;
      float x = ((Point)snakes[k].pos.get(0)).x;
      float y = ((Point)snakes[k].pos.get(0)).y;
      float dd = dist(0,0,x,y);
      
      float ndx = random(10.0, 15)*dx + random(-8,8)*dy; 
      float ndy = random(10.0, 15)*dy - random(-8,8)*dx; 
      if (dd>1000){
        ndx += -x*(dd-1000)/dd;
        ndy += -y*(dd-1000)/dd;
      }
      
      moveSnake(snakes[k], x+ndx, y+ndy);
      if (testCollision(snakes[k])){
        for (int i=0; i<snakes[k].pos.size(); i++){
          Point m = (Point)snakes[k].pos.get(i);
          m.r = 10;
          if (i%2==0) foods.add(m);
        }
        snakes[k] = new Snake(names[k], 4, (int)random(1000), (int)random(1000), 128+64, 255, 0, 10*cos(k*PI/3), 10*sin(k*PI/3));
      }
    }

  
  
  for (int k=0   ; k<foods.size(); k++){
    Point f = (Point)foods.get(k);
    pushMatrix();
    translate(f.x-panX, f.y-panY);
    //taille nourriture
    scale(0.2+sqrt(f.r)/2.7);
    //Q4
    float m=30+30*sin(millis()/150);
    
    fill(255,m);
    ellipse(0, 0, 13, 18);
    
    fill(70,50,40);
    ellipse(0, 0, 10, 15);
    fill(28,5,5);
    rect(0,0,3,-9);
    bezier(-6,-3,-7,-10,7,-10,6,3);
    popMatrix();
  }
    
  for (int k=0; k<snakes.length; k++){
    if (snakes[k]!=null)
      drawSnake(snakes[k]);
  }
  
  noFill();
  stroke(0, 128);
  //Q3 
  //dessine les etoiles horizontalement
 for (int a=0;a<width-2*BORDER_SIZE;a=a+35){
    etoile(a, BORDER_SIZE,BORDER_SIZE , 7,15);
    etoile(a, BORDER_SIZE,height-BORDER_SIZE , 7,15);
    

  }  
  //dessine les etoiles verticalment
  for (int a=35;a<height-2*BORDER_SIZE-35;a=a+35){
    etoile(0, BORDER_SIZE,a+BORDER_SIZE , 7,15);
    etoile(width, -BORDER_SIZE,a+BORDER_SIZE , 7,15);    

  }  
    
 // rect(BORDER_SIZE, BORDER_SIZE, width-2*BORDER_SIZE, height-2*BORDER_SIZE); 
 

  // Q9 quadricoptere
  translate(mouseX,mouseY);
  pushMatrix();
  
  image(img5, 0, 0);
  
  translate(-3*img5.width/4 , -10);
  scale(2,0.5);
  image(img5, 0, 0);
  translate(0, 40);
  image(img5, 0, 0);
  translate(3*img5.width/4 , 0);
  image(img5, 0, 0);
  translate(0 ,-40);
  image(img5, 0, 0);

  popMatrix();
  
  

  
}
 
void keyPressed() {
  if (state>0){
    snakes[0] = new Snake(names[0], 4, width/2, height/2, 20, 225, 255, 10, 0); 
    state = 0;
  }
  else if(key==' ' && snakes[0].weight>42)
    snakes[0].speed =20;  
}
void keyReleased() {
  if(snakes[0]!=null && key==' ')
    snakes[0].speed =10;
}
 
