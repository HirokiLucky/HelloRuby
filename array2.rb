Pixel = Struct.new(:r, :g, :b)
$img = Array.new(200) do
    Array.new(300) do Pixel.new(255,255,255) end
end
def pset(x, y, r, g, b)
    if 0 <= x && x < 300 && 0 <= y && y < 200
        $img[y][x].r = r; $img[y][x].g = g; $img[y][x].b = b
    end
end
def pseta(x, y, r=0, g=0, b=0, a=0.0)
    if x < 0 || x >= 300 || y < 0 || y >= 200 then return end
    $img[y][x].r = ($img[y][x].r * a + r * (1.0 - a)).to_i
    $img[y][x].g = ($img[y][x].g * a + g * (1.0 - a)).to_i
    $img[y][x].b = ($img[y][x].b * a + b * (1.0 - a)).to_i
end
def writeimage(name)
    open(name, "wb") do |f|
        f.puts("P6\n300 200\n255")
        $img.each do |a|
            a.each do |p| f.write(p.to_a.pack("ccc")) end
        end
    end
end
def fillstar(x, y, x0, y0, rad)
    theta = Math.atan2(y - (y0 - rad/4),      x - (x0 - rad))       * 180 / Math::PI
    beta  = Math.atan2(y - (y0 - rad/4),      x - (x0 + rad))       * 180 / Math::PI
    alfa  = Math.atan2(y - (y0 - rad),        x - x0)               * 180 / Math::PI
    zeta  = Math.atan2(y - (y0 + rad * 3/4),  x - (x0 - rad * 3/4)) * 180 / Math::PI
    delta = Math.atan2(y - (y0 + rad * 3/4),  x - (x0 + rad * 3/4)) * 180 / Math::PI
    if x0 > x
        if !(theta > 36 || theta < 0) then pset(x, y, 255, 255, 0) end
    end
    if x0 <= x
        if !(beta < 144 || beta > 180) then pset(x, y, 255, 255, 0) end 
    end
    if y0 >= y
        if !(alfa < 72 || alfa > 108) then pset(x, y, 255, 255, 0) end 
    end
    if y0 <= y && x0 > x
        if !(zeta < -54 || zeta > -18) then pset(x, y, 255, 255, 0) end 
    end
    if y0 <= y && x0 < x
        if !(delta < -162 || delta > -126) then pset(x, y, 255, 255, 0) end 
    end
end    

def fillcircle(x0, y0, rad, r=0, g=0, b=0)
    200.times do |y|
        300.times do |x|
            if (x-x0)**2 + (y-y0)**2 <= rad**2
                if block_given? then yield x, y
                else pset(x, y, r, g, b)
                end
            end
        end
    end
end
def fillcirclea(x, y, rad, r=0, g=0, b=0, a=0.0)
    j0 = (y-rad).to_i; j1 = (y+rad).to_i
    i0 = (x-rad).to_i; i1 = (x+rad).to_i
    j0.step(j1) do |j|
        i0.step(i1) do |i|
            if (i-x)**2+(j-y)**2<rad**2
                if block_given? then yield(i,j) 
                else pseta(i,j,r,g,b,a) 
                end
            end
        end
    end
end

def fillellipse(x, y, rx, ry, r=0, g=0, b=0, a=0.0)
    j0 = (y-ry).to_i; j1 = (y+ry).to_i
    i0 = (x-rx).to_i; i1 = (x+rx).to_i
    j0.step(j1) do |j|
        i0.step(i1) do |i|
            if ((i-x).to_f/rx)**2 + ((j-y).to_f/ry)**2 < 1.0
                if block_given? then yield(i,j) else pseta(i,j,r,g,b,a) end
            end
        end
    end
end

def fillrotellipse(x, y, rx, ry, theta, r=0, g=0, b=0, a=0.0)
    d = (if rx > ry then rx else ry end)
    j0 = (y-d).to_i; j1 = (y+d).to_i
    i0 = (x-d).to_i; i1 = (x+d).to_i
    j0.step(j1) do |j|
        i0.step(i1) do |i|
            dx = i - x; dy = j - y;
            px = dx*Math.cos(theta) - dy*Math.sin(theta)
            py = dx*Math.sin(theta) + dy*Math.cos(theta)
            if (px/rx)**2 + (py/ry)**2 < 1.0
                if block_given? then yield(i,j) else pseta(i,j,r,g,b,a) end
            end
        end
    end
end

def linex(x, y, length, r, g, b)
    length.times do |i| pset(x + i, y, r, g, b) end
end
def liney(x, y, length, r, g, b)
    length.times do |i| pset(x, y + i, r, g, b) end
end
def slantlineRightShoulder(x, y, length, r, g, b)
    length.times do |i| pset(x + i, y - i, r, g, b) end
end
def slantlineLeftShoulder(x, y, length, r, g, b)
    length.times do |i| pset(x + i, y + i, r, g, b) end
end

def fillline(x0, y0, x1, y1, w, r=0, g=0, b=0, a=0.0)
    dx = y1-y0; dy = x0-x1; n = 0.5*w / Math.sqrt(dx**2 + dy**2)
    dx = dx * n; dy = dy * n
    if block_given?
        fillconvex([x0-dx,x0+dx,x1+dx,x1-dx,x0-dx],
        [y0-dy,y0+dy,y1+dy,y1-dy,y0-dy]) do |x,y| yield(x,y) end
    else
        fillconvex([x0-dx, x0+dx, x1+dx, x1-dx, x0-dx],
        [y0-dy, y0+dy, y1+dy, y1-dy, y0-dy], r, g, b, a)
    end
end

def square(x, y, width, height, r, g, b)
    width.times do |v|
        pset(x + v, y, r, g, b); pset(x + v, y + height, r, g, b)
    end
    height.times do |v|
        pset(x, y + v, r, g, b); pset(x + width, y + v, r, g, b)
    end
end

def fillsquare(x, y, width, height, r, g, b, a)
    width.times do |v|
        height.times do |w|
            pseta(x + v, y + w, r, g, b, a)
        end
    end
end

def fillrect(x, y, w, h, r=0, g=0, b=0, a=0.0)
    j0 = (y-0.5*h).to_i; j1 = (y+0.5*h).to_i
    i0 = (x-0.5*w).to_i; i1 = (x+0.5*w).to_i
    j0.step(j1) do |j|
        i0.step(i1) do |i|
            if block_given? then yield(i,j) else pseta(i,j,r,g,b,a) end
        end
    end
end

def filldonut(x, y, r1, r2, r=0, g=0, b=0, a=0.0)
    j0 = (y-r1).to_i; j1 = (y+r1).to_i
    i0 = (x-r1).to_i; i1 = (x+r1).to_i
    j0.step(j1) do |j|
        i0.step(i1) do |i|
            d2 = (i-x)**2+(j-y)**2
            if r2**2 <= d2 && d2 <= r1**2
                if block_given? then yield(i,j) else pseta(i,j,r,g,b,a) end
            end
        end
    end
end

def filltriangle(x0, y0, x1, y1, x2, y2, r, g, b, a = 0.0)
    if block_given?
        fillconvex([x0,x1,x2,x0], [y0,y1,y2,y0]) do |x,y| yield(x,y) end
        fillconvex([x0,x2,x1,x0], [y0,y2,y1,y0]) do |x,y| yield(x,y) end
    else
        fillconvex([x0, x1, x2, x0], [y0, y1, y2, y0], r, g, b, a)
        fillconvex([x0, x2, x1, x0], [y0, y2, y1, y0], r, g, b, a)
    end
end

def fillconvex(ax, ay, r=0, g=0, b=0, a=0.0)
    xmax = ax.max.to_i; xmin = ax.min.to_i
    ymax = ay.max.to_i; ymin = ay.min.to_i
    ymin.step(ymax) do |j|
        xmin.step(xmax) do |i|
            if isinside(i, j, ax, ay)
                if block_given? then yield(i,j) else pseta(i,j,r,g,b,a) end
            end
        end
    end
end

def isinside(x, y, ax, ay)
    (ax.length-1).times do |i|
        if oprod(ax[i+1]-ax[i],ay[i+1]-ay[i],x-ax[i],y-ay[i])<0
            return false
        end
    end
    return true
end

def oprod(a, b, c, d)
    return a*d - b*c;
end

def gradation(r, g, a)
    200.times do |i|
        300.times do |j|
            pseta(j, i, r + i, g ,255 - i, a)
        end
    end
end

def sun(x, y, rad, r, g, b)
    fillcircle(x, y, rad / 2 , r, g, b)
    8.times do |i|
        fillcircle(rad * Math.cos(Math::PI/4 * i) + x, rad * Math.sin(Math::PI/4 * i) + y, 5, r, g, b)
    end
end


#def mypicture
#    pset(100, 80, 255, 0, 0)
#    writeimage("t.ppm")
#end

#def mypicture2
#   fillcircle(110, 100, 60, 255, 0, 0)
#    fillcircle(180, 120, 40, 100, 200, 80)
#    writeimage("t.ppm")
#end

def mypicture3
    #fillcircle(50,50,40) do |x,y|
    #    fillstar(x,y,50,50,40)
    #end
    #slantlineRightShoulder(150, 150, 200, 255, 0, 0)
    #slantlineLeftShoulder(150, 150, 200, 255, 0, 0)
    #linex(0, 20, 300, 0, 255, 0)
    #liney(20, 0, 300, 0, 0, 255)
    #square(50, 50, 40, 80, 0, 255,0)
    #fillsquare(50, 50, 40, 80, 0, 255,0, 0.9)
    #fillcirclea(50, 50, 40, 0, 255,0, 0.9)
    #filldonut(50, 50, 80, 40, 0, 255,0, 0.5)
    #fillrect(50, 50, 80, 40, 0, 255,0, 0.5)
    #fillellipse(50, 50, 80, 40, 0, 255,0, 0.5)
    #fillrotellipse(50, 50, 80, 40, 90, 0, 255,0, 0.5)
    #filltriangle(50, 10, 20, 50, 80, 50, 255, 0, 0, 0.1)
    #fillline(0, 10, 20, 50, 20, 255, 0, 0, 0.1)
    gradation(0, 0, 0)
    sun(50, 100, 30, 255, 0, 0)
    fillsquare(0, 150, 300, 50, 210, 255, 0, 0)
    fillcircle(100, 30, 10) do |x, y|
        fillstar(x, y, 100, 30, 10)
    end
    fillcircle(150, 40, 10) do |x, y|
        fillstar(x, y, 150, 40, 10)
    end
    fillcircle(280, 10, 10) do |x, y|
        fillstar(x, y, 280, 10, 10)
    end
    fillcircle(200, 20, 10) do |x, y|
        fillstar(x, y, 200, 20, 10)
    end
    fillcircle(230, 30, 10) do |x, y|
        fillstar(x, y, 230, 30, 10)
    end
    writeimage("t.ppm")
end

def frog
    fillellipse(150, 100, 120, 80, 0, 200, 0, 0.0)
    fillcircle(50, 50, 30, 0, 200, 0)
    fillcircle(250, 50, 30, 0, 200, 0)
    fillcircle(250, 50, 20, 0, 0, 0)
    fillcircle(50, 50, 20, 0, 0, 0)
    fillline(120, 100, 150, 120, 5, 0, 0, 0, 0.0)
    fillline(150, 120, 180, 100, 5, 0, 0, 0, 0.0)
    writeimage("t.ppm")
end
frog
#mypicture3
