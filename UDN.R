#the first version was written by Cai, Yun-Ting (leotsai0119) in 2015
#for the purpose of testing web crawlers
#and was for a friend Sylvia Tsai
#revised in 2018 Nov with CSS selector code by Cai, Yun-Ting(leotsai0119)

library(rvest)
library(magrittr)
library(data.table)
library(progress)

rm(list = ls())

#�e�m�@�~
#��UDN�����T�{����r�j�M�᭶����p #²�� #�C����ܼƭn���50
#keyword <- "((���g��OR��g��)+�ꥻ�D�q)" #keywords
keyword <- "APEC" #keywords
DateB <- 19500101 #�]�w�}�l���
DateE <- 20151231 #�]�w�������
news <- "�p�X��|�g�٤��|�p�X�߳�|Upaper"
p <- 2  #�]�w��������
t <- 15 #�]�w���j����
#�]�w����

#encoding URL #deafault in Win CP950
UDNsearch <- function(keyword, DateB, DateE, news, page = 1, sharepage = 50){

        root <- "http://udndata.com/ndapp/Searchdec?" #root
        
        paste(keyword, "+" , "���", ">=", DateB, "+", "���", "<=", 
              DateE, "+" , "���O", "=", news, sep="") %>% URLencode(reserved = TRUE) -> searchstring
        
        url <- paste(root, "&udndbid=udndata",  "&page=", page, "&SearchString=", 
                     searchstring, "&sharepage=", sharepage, "&select=0", "&kind=2",
                     "&showSearchString=", sep="")
        return(url)
        }

#crawler
UDNcrawler <- function(){
    
        pb <- progress_bar$new(
                format = "�B�z�� [:bar]:percent | �|��: :eta | �O��: :elapsed", 
                total = p, clear = FALSE, width= 80, show_after = 0
                ) 

        start <- Sys.time() #�����}�l�ɶ�
  
        #list
        title <- list()
        date <- list()
  
        #for.loop
        for(i in 1:p){
                url <- UDNsearch(keyword, DateB, DateE, news, page = i)
                doc <- read_html(url)
                html_nodes(doc, ".control-pic a") %>% html_text() -> title[[i]]
                html_nodes(doc, ".news span") %>% html_text() -> date[[i]]
                pb$tick()
                Sys.sleep(t)
                }
  
        #unlist
        title <- unlist(title)
        date <- unlist(date)
  
        #data.frame
        tstrsplit(date, "�D") -> d1 #���Τ���B���O�B�O��
        tstrsplit(title, ".", fixed = TRUE) -> t1 #���μи�
        d1[[1]] %>% tstrsplit("-") -> d2 #���Φ~���
  
        #dataframe �X�֦~�B��B��B���D�B���O�B�O��
        df <- cbind.data.frame(d2[[1]], d2[[2]], d2[[3]], t1[[2]], d1[[2]], d1[[5]])
  
        #�@keyword�ܼ�
        df$keyword <- keyword
  
        #variable names
        names(df) <- c("year", "month", "day", "title", "paper", "author", "keyword")
  
        #����
        end <- Sys.time() #���������ɶ�
        print(end - start) #��X�`��O�ɶ�
  
        return(df)
        }

#shutdown computer
shutdown <- function(wait = 0){
        Sys.sleep(wait)
        ifelse(.Platform$OS.type == "windows", shell("shutdown -s -t 0"), 
        system("shutdown -h now"))
        }


#test with keyword "APEC"
df <- UDNcrawler()