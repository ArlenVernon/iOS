//
//  ViewController.swift
//  打打打砖块
//
//  Created by arlen on 2017/4/28.
//  Copyright © 2017年 arlen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        let startButton = UIButton(frame:CGRect(x:141, y:323, width:100, height:80))
        startButton.setTitle("start", for: UIControlState.normal)
        startButton.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: UIControlState.normal)
        startButton.setTitleColor(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), for: UIControlState.highlighted)
        startButton.titleLabel?.font = UIFont(name:"Zapfino", size:25)
        startButton.addTarget(self, action: #selector(ViewController.startSButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(startButton)
        
        let titleLabel = UILabel(frame:CGRect(x:116, y:20, width:200, height:120))
        titleLabel.text = "Welcome to Blocks!"
        titleLabel.font = UIFont(name:"Zapfino", size:15)
        self.view.addSubview(titleLabel)
    }
    
    func startSButton(){
        NSLog("start game")
        let secondView  = SecondViewController()
        self.present(secondView, animated: true, completion: nil)
    }
}

class SecondViewController : UIViewController{
    var blocks = [UIView]()
    let blockCount: Int = 4
    lazy var ball = UIView()
    lazy var startlabel = UILabel()
    lazy var pan = UIView()
    
    var tapRecognizer: UITapGestureRecognizer!              //点击，轻触摸
    var panRecognizer: UIPanGestureRecognizer!              //拖移
    var panSpeed: CGFloat = 0                            //CGFloat：浮点值的基本类型
    var ballSpeed: CGPoint = CGPoint(x:0, y:0)           //CGPoint：表示一个二维坐标系的点
    
    var Timer: CADisplayLink?
    override func viewDidLoad() {
        super.viewDidLoad()                                 //去当前类的父类中寻找viewDidLoad这个方法
        self.view.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        setUI()                                             //放入图形
        setGesture()                                        //放入动作
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setGesture(){
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(SecondViewController.tap))
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(SecondViewController.move))
        self.view.addGestureRecognizer(pan)       //把panRecognizer手势添加到视图中
        self.view.addGestureRecognizer(tap)                 //把tap手势添加到视图中
    }
    
    func setUI(){
        ball.frame = CGRect(x: 160, y: 506, width: 18, height: 18)
        ball.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        ball.layer.cornerRadius = ball.frame.width / 2
        ball.center = CGPoint (x: 160, y: 506)
        view.addSubview(ball)
        
        pan.frame = CGRect(x: 150, y:520, width: 80, height: 10)
        pan.backgroundColor = #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1)
        pan.center = CGPoint(x: 160, y:520)
        view.addSubview(pan)
        
        
        for i in 0...15 {
            let line : Int = i % blockCount
            let row : Int = i / blockCount
            let blockW : CGFloat = view.frame.width / CGFloat(blockCount)
            let blockH : CGFloat = 30
            let blockX : CGFloat = CGFloat(line) * blockW
            let blockY : CGFloat = CGFloat(row) * blockH
            let block = UIView(frame : CGRect(x : blockX, y : blockY, width : blockW, height : blockH))
            
            block.layer.borderWidth = 1
            block.layer.borderColor = UIColor.white.cgColor
            block.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            view.addSubview(block)
            blocks.append(block)
        }
    }
    
    func timeUpdate(){
        print("seconds")
        wallHit()
        panHit()
        blockHit()
        failed()
        succeed()
        ball.center = CGPoint(x: ball.center.x + ballSpeed.x, y: ball.center.y + ballSpeed.y)
    }
    
    func tap(){
        if ballSpeed == CGPoint(x: 0 , y: 0) {
            print("game starts!")
            for block in blocks {
                block.isHidden = false
            }
            ballSpeed = CGPoint(x: -1.5 , y: -1.8)
            Timer = CADisplayLink(target: self, selector: #selector(SecondViewController.timeUpdate))
            Timer!.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        
    }
    
    func move(sender: AnyObject){
        let panRecognizer = sender as! UIPanGestureRecognizer
        if panRecognizer.state == UIGestureRecognizerState.changed{
            let location = panRecognizer.location(in: self.view)
            self.pan.center = CGPoint(x: location.x, y: self.pan.center.y)
            panSpeed = panRecognizer.velocity(in: self.view).x / 120.0
        }
        if panRecognizer.state == UIGestureRecognizerState.ended{
            panSpeed = 0
        }
    }
    
    func wallHit(){
        if ball.frame.origin.x < 0.0 {
            ballSpeed = CGPoint(x: abs(ballSpeed.x), y: ballSpeed.y)
        }
        if ball.frame.maxX > UIScreen.main.bounds.size.width {
            ballSpeed = CGPoint(x: -abs(ballSpeed.x), y: ballSpeed.y)
        }
        
        if ball.frame.origin.y < 0.0 {
            ballSpeed = CGPoint(x: ballSpeed.x, y: abs(ballSpeed.y))
        }
    }
    
    func panHit(){
        if ball.frame.intersects(pan.frame){
            ballSpeed = CGPoint(x: ballSpeed.x + panSpeed, y: -abs(ballSpeed.y))
        }
    }
    
    func blockHit(){
        for b in blocks{
            if ball.frame.intersects(b.frame) && b.isHidden == false {
                ballSpeed = CGPoint(x: ballSpeed.x, y: abs(ballSpeed.y))
                b.isHidden = true
            }
        }
    }
    
    func failed(){
        if ball.frame.maxY > UIScreen.main.bounds.size.height {
            Timer!.invalidate()
            let failedView = FailedViewController()
            self.present(failedView, animated: true, completion: nil)
        }
    }
    
    func succeed(){
        var success = false
        for block in blocks {
            if block.isHidden == true {
                success = false
            }
        }
        if success == true {
            Timer!.invalidate()
            let succeedView = SucceedViewController()
            self.present(succeedView, animated: true, completion: nil)
        }
    }
    
}
class FailedViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        let resumeButton = UIButton(frame:CGRect(x: 141,  y:323, width:100, height:80))
        resumeButton.setTitle("try again", for: UIControlState.normal)
        resumeButton.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: UIControlState.normal)
        resumeButton.setTitleColor(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), for: UIControlState.highlighted)
        resumeButton.titleLabel?.font = UIFont(name:"Zapfino", size : 15)
        resumeButton.addTarget(self, action: #selector(FailedViewController.reButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(resumeButton)
        
        let titleLabel = UILabel(frame:CGRect(x:116, y:20, width:200, height:120))
        titleLabel.text = "Cheer Up!"
        titleLabel.font = UIFont(name:"Zapfino", size:15)
        self.view.addSubview(titleLabel)
    }
    func reButton(){
        NSLog("resume game")
        let secondView  = SecondViewController()
        self.present(secondView, animated: true, completion: nil)
    }
}

class SucceedViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        let tryAgainButton = UIButton(frame:CGRect(x: 141,  y:323, width:100, height:80))
        tryAgainButton.setTitle("resume", for: UIControlState.normal)
        tryAgainButton.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: UIControlState.normal)
        tryAgainButton.setTitleColor(#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1), for: UIControlState.highlighted)
        tryAgainButton.titleLabel?.font = UIFont(name:"Zapfino", size : 25)
        tryAgainButton.addTarget(self, action: #selector(SucceedViewController.tryButton), for: UIControlEvents.touchUpInside)
        self.view.addSubview(tryAgainButton)
        
        let titleLabel = UILabel(frame:CGRect(x:116, y:20, width:200, height:120))
        titleLabel.text = "Wonderful!"
        titleLabel.font = UIFont(name:"Zapfino", size:15)
        self.view.addSubview(titleLabel)
    }
    func tryButton(){
        NSLog("try again")
        let secondView  = SecondViewController()
        self.present(secondView, animated: true, completion: nil)
    }
}
