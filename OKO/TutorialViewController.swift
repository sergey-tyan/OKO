//
//  TutorialViewController.swift
//  OKO
//
//  Created by Aider on 07.12.15.
//  Copyright © 2015 oko. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class TutorialViewController: UIViewController, UIScrollViewDelegate {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let imageNames :[String] = ["page1", "page2", "page3", "page4"]
    let animationNames :[String] = ["gif1", "gif2", "gif3", "gif4"]
    let titles :[String] = ["ДОБРО ПОЖАЛОВАТЬ В ОКО!", "HUD - РЕЖИМ", "ФИЛЬТР ДОРОЖНЫХ ЗНАКОВ", "ДОБАВЛЕНИЕ УГРОЗ"]
    let texts :[String] = ["Новое бесплатное приложение для обнаржуения различных дорожных опасностей.", "Для запуска достаточно коснуться кнопки включения, затем поместить смартфон под лобовое стекло в горизонтальном положении.", "Убрав отметку в фильтре дорожных знаков, Вы отключаете оповещения о данном типе знаков и убираете их с карты.", "Пользователи сами формируют и обновляют общую базу данных, добавляя новую информацию об обнаруженных объектах."]

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        if ((userDefaults.objectForKey("show_tutorial")) != nil){
            self.performSegueWithIdentifier("openMap", sender: nil)
        }else{
            userDefaults.setObject("1", forKey: "show_tutorial");
            userDefaults.synchronize()
        }

        
        scrollView.delegate = self
    }
    
    var frame: CGRect = CGRectMake(0, 0, 0, 0)

    @IBOutlet weak var skipButton: UIButton!
    
    
    override func viewDidAppear(animated: Bool) {
        scrollView.contentSize = CGSizeMake(scrollView.frame.width * 4, scrollView.frame.height);
        scrollView.pagingEnabled = true
        
        
        let width = self.scrollView.frame.size.width;
        for page in 0..<4 {
            
            frame.origin.x = width * CGFloat(page)
            frame.size = self.scrollView.frame.size
            
            
            let subView = UIView(frame: frame)
            subView.backgroundColor = UIColor(colorLiteralRed: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1.0)
            
            let imageView = UIImageView(frame: CGRectMake(0.15 * width, 0.2 * width, 0.7 * width, 0.7 * width))
            //imageView.image = UIImage(named: imageNames[page])
            if(page == 0){
                imageView.image = UIImage(named: imageNames[page])
            }else{
                imageView.image = UIImage.gifWithName(animationNames[page])
            }
            print("initiating gif \(page)")
            
            subView.addSubview(imageView)
            
            let headerLabel = UILabel(frame: CGRectMake(0.1 * width, width, 0.8 * width, 0.066 * width))
            headerLabel.text = titles[page]
            headerLabel.textColor = UIColor(colorLiteralRed: 78.0/255.0, green: 78.0/255.0, blue: 78.0/255.0, alpha: 1.0)
            headerLabel.font = UIFont.boldSystemFontOfSize(16.0)
            headerLabel.textAlignment = .Center;
            subView.addSubview(headerLabel)
            
            let bodyLabel = UILabel(frame: CGRectMake(0.1 * width, headerLabel.frame.height + 15 + headerLabel.frame.origin.y, 0.8 * width , 0.24 * width))
            bodyLabel.text = texts[page]
            bodyLabel.textColor = UIColor(colorLiteralRed: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
            bodyLabel.font = UIFont.systemFontOfSize(15.0)
            bodyLabel.textAlignment = .Center;
            bodyLabel.lineBreakMode = .ByWordWrapping
            bodyLabel.numberOfLines = 4
            subView.addSubview(bodyLabel)
            
            self.scrollView .addSubview(subView)
        }
        

    }
    
    override func viewDidLayoutSubviews() {
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        
        print(pageControl.currentPage)
        
        if (pageControl.currentPage == 3){
            
            skipButton.setTitle("ПРОДОЛЖИТЬ", forState: UIControlState.Normal)
            skipButton.setTitleColor(UIColor(colorLiteralRed: 255.0/255.0, green: 112.0/255.0, blue: 91.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
            skipButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14.0)

        }else{
            skipButton.setTitle("ПРОПУСТИТЬ", forState: UIControlState.Normal)
            skipButton.setTitleColor(UIColor(colorLiteralRed: 78.0/255.0, green: 78.0/255.0, blue: 78.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
            skipButton.titleLabel?.font = UIFont.systemFontOfSize(14.0)
        }
    }
    

    @IBAction func openMap(sender: AnyObject) {
        self.performSegueWithIdentifier("openMap", sender: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
