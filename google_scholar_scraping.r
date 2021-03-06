## Visualizaiton of citations and coauthor citations from scraping goolge scholar

browseURL("http://www.r-bloggers.com/google-scholar-scraping-with-rvest-package/") # Original post

library(rvest)
library(ggplot2)

# Let’s use SelectorGadget to find out which css selector matches the “cited by” column.
page <- read_html("https://scholar.google.com/citations?user=acxXDGQAAAAJ&hl=en")

# Specify the css selector in html_nodes() and extract the text with html_text(). Finally, change the string to numeric using as.numeric().
citations <- page %>% html_nodes ("#gsc_a_b .gsc_a_c") %>% html_text()%>%as.numeric()

# See the number of citations:
citations 

# Create a barplot of the number of citation:
barplot(citations, main="Times Each Paper Cited", ylab='Number of citations', col="skyblue", xlab="", ylim = c(0,5))

# Let's check citations of co-authors
page <- read_html("https://scholar.google.com/citations?view_op=list_colleagues&hl=en&user=acxXDGQAAAAJ")

Coauthors = page%>% html_nodes(css=".gsc_1usr_name a") %>% html_text()
Coauthors = as.data.frame(Coauthors)
names(Coauthors)='Coauthors'

# Now let’s explore Coauthors
head(Coauthors) 
dim(Coauthors) # Number of coauthors

# How many times coauthors have been cited
page <- read_html("https://scholar.google.com/citations?view_op=list_colleagues&hl=en&user=acxXDGQAAAAJ")

Citations = page%>% html_nodes(css = ".gsc_1usr_cby")%>%html_text()
Citations

# Extract numeric characters using global substitute
Citations = gsub('Cited by','', citations)
Citations

# Change string to numeric and then to data frame to make it easy to use with ggplot2
Citations = as.numeric(citations)
Citations = as.data.frame(citations)

### Affiliation of Coauthors
# Affiliation of coauthors
page <- read_html("https://scholar.google.com/citations?view_op=list_colleagues&hl=en&user=acxXDGQAAAAJ")

affilation = page %>% html_nodes(css = ".gsc_1usr_aff")%>%html_text()
affilation = as.data.frame(affilation)
names(affilation)='Affilation'

# Now, let’s create a data frame that consists of coauthors, citations and affilations

cauthors=cbind(Coauthors, citations, affilation)

cauthors 

xtable(cauthors)

# Re-order coauthors based on their citations
# Let’s re-order coauthors based on their citations so as to make our plot in a decreasing order.
cauthors$Coauthors <- factor(cauthors$Coauthors, levels = cauthors$Coauthors[order(cauthors$citations, decreasing=F)])

# Plot coauthors by number of citations
ggplot(cauthors,aes(Coauthors,citations))+geom_bar(stat="identity", fill="#046c9a",size=5)+
  theme(axis.title.y   = element_blank())+ylab("# of citations")+
  theme(plot.title=element_text(size = 18,colour="black"), axis.text.y = element_text(colour="grey20",size=12))+
  ggtitle('Citations of Coauthors')+coord_flip()

